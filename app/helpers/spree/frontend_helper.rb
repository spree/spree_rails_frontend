module Spree
  module FrontendHelper
    include BaseHelper
    include InlineSvg::ActionView::Helpers

    class CachedPropertyPresenter < Spree::Filters::PropertyPresenter
      def initialize(property:, uniq_values:)
        @property = property
        @product_properties = Spree::ProductProperty.none
        @uniq_values = uniq_values
      end

      def product_properties
        fail "Not implemented (CachedPropertyPresenter)"
      end

      def uniq_values
        @uniq_values
      end
    end

    def body_class
      @body_class ||= content_for?(:sidebar) ? 'two-col' : 'one-col'
      @body_class
    end

    def logo(image_path = nil, options = {})
      logo_attachment = if defined?(Spree::StoreLogo) && current_store.logo.is_a?(Spree::StoreLogo)
                          current_store.logo.attachment # Spree v5
                        else
                          current_store.logo # Spree 4.x
                        end

      image_path ||= if logo_attachment&.attached? && logo_attachment&.variable?
                       main_app.cdn_image_url(logo_attachment.variant(resize_to_limit: [244, 104]))
                     elsif logo_attachment&.attached? && logo_attachment&.image?
                       main_app.cdn_image_url(logo_attachment)
                     else
                       asset_path('logo/spree_50.png')
                     end

      path = spree.respond_to?(:root_path) ? spree.root_path : main_app.root_path

      link_to path, 'aria-label': current_store.name, method: options[:method] do
        image_tag image_path, alt: current_store.name, title: current_store.name
      end
    end

    def spree_breadcrumbs(taxon, _separator = '', product = nil)
      return '' if current_page?('/') || taxon.nil?

      # breadcrumbs for root
      crumbs = [content_tag(:li, content_tag(
        :a, content_tag(
          :span, Spree.t(:home), itemprop: 'name'
        ) << content_tag(:meta, nil, itemprop: 'position', content: '0'), itemprop: 'url', href: spree.root_path
      ) << content_tag(:span, nil, itemprop: 'item', itemscope: 'itemscope', itemtype: 'https://schema.org/Thing', itemid: spree.root_path), itemscope: 'itemscope', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement', class: 'breadcrumb-item')]

      if taxon
        ancestors = taxon.ancestors.where.not(parent_id: nil)

        # breadcrumbs for ancestor taxons
        crumbs << ancestors.each_with_index.map do |ancestor, index|
          content_tag(:li, content_tag(
            :a, content_tag(
              :span, ancestor.name, itemprop: 'name'
            ) << content_tag(:meta, nil, itemprop: 'position', content: index + 1), itemprop: 'url', href: seo_url(ancestor, params: permitted_product_params)
          ) << content_tag(:span, nil, itemprop: 'item', itemscope: 'itemscope', itemtype: 'https://schema.org/Thing', itemid: seo_url(ancestor, params: permitted_product_params)), itemscope: 'itemscope', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement', class: 'breadcrumb-item')
        end

        # breadcrumbs for current taxon
        crumbs << content_tag(:li, content_tag(
          :a, content_tag(
            :span, taxon.name, itemprop: 'name'
          ) << content_tag(:meta, nil, itemprop: 'position', content: ancestors.size + 1), itemprop: 'url', href: seo_url(taxon, params: permitted_product_params)
        ) << content_tag(:span, nil, itemprop: 'item', itemscope: 'itemscope', itemtype: 'https://schema.org/Thing', itemid: seo_url(taxon, params: permitted_product_params)), itemscope: 'itemscope', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement', class: 'breadcrumb-item')

        # breadcrumbs for product
        if product
          crumbs << content_tag(:li, content_tag(
            :span, content_tag(
              :span, product.name, itemprop: 'name'
            ) << content_tag(:meta, nil, itemprop: 'position', content: ancestors.size + 2), itemprop: 'url', href: spree.product_path(product, taxon_id: taxon&.id)
          ) << content_tag(:span, nil, itemprop: 'item', itemscope: 'itemscope', itemtype: 'https://schema.org/Thing', itemid: spree.product_path(product, taxon_id: taxon&.id)), itemscope: 'itemscope', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement', class: 'breadcrumb-item')
        end
      else
        # breadcrumbs for product on PDP
        crumbs << content_tag(:li, content_tag(
          :span, Spree.t(:products), itemprop: 'item'
        ) << content_tag(:meta, nil, itemprop: 'position', content: '1'), class: 'active', itemscope: 'itemscope', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement')
      end
      crumb_list = content_tag(:ol, raw(crumbs.flatten.map(&:mb_chars).join), class: 'breadcrumb', itemscope: 'itemscope', itemtype: 'https://schema.org/BreadcrumbList')
      content_tag(:nav, crumb_list, id: 'breadcrumbs', class: 'col-12 mt-1 mt-sm-3 mt-lg-4', aria: { label: Spree.t(:breadcrumbs) })
    end

    def class_for(flash_type)
      {
        success: 'success',
        registration_error: 'danger',
        error: 'danger',
        alert: 'danger',
        warning: 'warning',
        notice: 'success'
      }[flash_type.to_sym]
    end

    def checkout_progress(numbers: false)
      states = @order.checkout_steps - ['complete']
      items = states.each_with_index.map do |state, i|
        text = Spree.t("order_state.#{state}").titleize
        text.prepend("#{i.succ}. ") if numbers

        css_classes = ['text-uppercase nav-item']
        current_index = states.index(@order.state)
        state_index = states.index(state)

        if state_index < current_index
          css_classes << 'completed'
          link_content = content_tag :span, nil, class: 'checkout-progress-steps-image checkout-progress-steps-image--full'
          link_content << text
          text = link_to(link_content, spree.checkout_state_path(state), class: 'd-flex flex-column align-items-center', method: :get)
        end

        css_classes << 'next' if state_index == current_index + 1
        css_classes << 'active' if state == @order.state
        css_classes << 'first' if state_index == 0
        css_classes << 'last' if state_index == states.length - 1
        # No more joined classes. IE6 is not a target browser.
        # Hack: Stops <a> being wrapped round previous items twice.
        if state_index < current_index
          content_tag('li', text, class: css_classes.join(' '))
        else
          link_content = if state == @order.state
                           content_tag :span, nil, class: 'checkout-progress-steps-image checkout-progress-steps-image--full'
                         else
                           inline_svg_tag 'circle.svg', class: 'checkout-progress-steps-image'
                         end
          link_content << text
          content_tag('li', content_tag('a', link_content, class: "d-flex flex-column align-items-center #{'active' if state == @order.state}"), class: css_classes.join(' '))
        end
      end
      content = content_tag('ul', raw(items.join("\n")), class: 'nav justify-content-between checkout-progress-steps', id: "checkout-step-#{@order.state}")
      hrs = '<hr />' * (states.length - 1)
      content << content_tag('div', raw(hrs), class: "checkout-progress-steps-line state-#{@order.state}")
    end

    def flash_messages(opts = {})
      flashes = ''
      excluded_types = opts[:excluded_types].to_a.map(&:to_s)

      flash.to_h.except('order_completed').each do |msg_type, text|
        next if msg_type.blank? || excluded_types.include?(msg_type)

        flashes << content_tag(:div, class: "alert alert-#{class_for(msg_type)} mb-0") do
          content_tag(:button, '&times;'.html_safe, class: 'close', data: { dismiss: 'alert', hidden: true }) +
            content_tag(:span, text)
        end
      end
      flashes.html_safe
    end

    def link_to_cart(text = nil)
      text = text ? h(text) : Spree.t('cart')
      css_class = nil

      if simple_current_order.nil? || simple_current_order.item_count.zero?
        text = "<span class='glyphicon glyphicon-shopping-cart'></span> #{text}: (#{Spree.t('empty')})"
        css_class = 'empty'
      else
        text = "<span class='glyphicon glyphicon-shopping-cart'></span> #{text}: (#{simple_current_order.item_count})
                <span class='amount'>#{simple_current_order.display_total.to_html}</span>"
        css_class = 'full'
      end

      link_to text.html_safe, spree.cart_path, class: "cart-info nav-link #{css_class}"
    end

    def asset_exists?(path)
      if Rails.configuration.assets.compile
        Rails.application.precompiled_assets.include? path
      else
        Rails.application.assets_manifest.assets[path].present?
      end
    end

    def plp_and_carousel_image(product, image_class = '')
      image = default_image_for_product_or_variant(product)

      image_url = if image.present?
                    main_app.cdn_image_url(image.url('plp'))
                  else
                    asset_path('noimage/large.png')
                  end

      image_style = image&.style(:plp)

      lazy_image(
        src: image_url,
        srcset: carousel_image_source_set(image),
        alt: product.name,
        width: image_style&.dig(:width) || 278,
        height: image_style&.dig(:height) || 371,
        class: "product-component-image d-block mw-100 #{image_class}"
      )
    end

    def lazy_image(src:, alt:, width:, height:, srcset: '', **options)
      # We need placeholder image with the correct size to prevent page from jumping
      placeholder = "data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20viewBox='0%200%20#{width}%20#{height}'%3E%3C/svg%3E"

      image_tag placeholder, data: { src: src, srcset: srcset }, class: "#{options[:class]} lazyload", alt: alt
    end

    def permitted_product_params
      product_filters = available_option_types.map(&:name)
      params.permit(product_filters << :sort_by)
    end

    def carousel_image_source_set(image)
      return '' unless image

      widths = { lg: 1200, md: 992, sm: 768, xs: 576 }
      set = []
      widths.each do |key, value|
        file = main_app.cdn_image_url(image.url("plp_and_carousel_#{key}"))

        set << "#{file} #{value}w"
      end
      set.join(', ')
    end

    def image_source_set(name)
      widths = {
        desktop: '1200',
        tablet_landscape: '992',
        tablet_portrait: '768',
        mobile: '576'
      }
      set = []
      widths.each do |key, value|
        filename = key == :desktop ? name : "#{name}_#{key}"
        file = asset_path("#{filename}.jpg")

        set << "#{file} #{value}w"
      end
      set.join(', ')
    end

    def taxons_tree(root_taxon, current_taxon, max_level = 1)
      return '' if max_level < 1 || root_taxon.leaf?

      content_tag :div, class: 'list-group' do
        taxons = root_taxon.children.map do |taxon|
          css_class = current_taxon&.self_and_ancestors&.include?(taxon) ? 'list-group-item list-group-item-action active' : 'list-group-item list-group-item-action'
          link_to(taxon.name, seo_url(taxon), class: css_class) + taxons_tree(taxon, current_taxon, max_level - 1)
        end
        safe_join(taxons, "\n")
      end
    end

    def set_image_alt(image)
      return image.alt if image.alt.present?
    end

    def icon(name:, classes: '', width:, height:)
      inline_svg_tag "#{name}.svg", class: "spree-icon #{classes}", size: "#{width}px*#{height}px"
    end

    def price_filter_values
      Spree::Deprecation.warn(<<-DEPRECATION, caller)
        `FrontendHelper#price_filter_values` is deprecated and will be removed in Spree 5.0.
        Please use `ProductsFiltersHelper#price_filters` method
      DEPRECATION

      @price_filter_values ||= [
        "#{I18n.t('activerecord.attributes.spree/product.less_than')} #{formatted_price(50)}",
        "#{formatted_price(50)} - #{formatted_price(100)}",
        "#{formatted_price(101)} - #{formatted_price(150)}",
        "#{formatted_price(151)} - #{formatted_price(200)}",
        "#{formatted_price(201)} - #{formatted_price(300)}"
      ]
    end

    def static_filters
      @static_filters ||= Spree::Frontend::Config[:products_filters]
    end

    def additional_filters_partials
      @additional_filters_partials ||= Spree::Frontend::Config[:additional_filters_partials]
    end

    def filtering_params
      @filtering_params ||= available_option_types.map(&:filter_param).concat(static_filters)
    end

    def filtering_params_cache_key
      @filtering_params_cache_key ||= begin
        cache_key_parts = []

        permitted_products_params.each do |key, value|
          next if value.blank?

          if value.is_a?(String)
            cache_key_parts << [key, value].join('-')
          else
            value.each do |part_key, part_value|
              next if part_value.blank?

              cache_key_parts << [part_key, part_value].join('-')
            end
          end
        end

        cache_key_parts.join('-').parameterize
      end
    end

    def filters_cache_key(kind)
      base_cache_key + [
        kind,
        available_option_types_cache_key,
        available_properties_cache_key,
        filtering_params_cache_key,
        @taxon&.id,
        params[:menu_open]
      ].flatten
    end

    def permitted_products_params
      @permitted_products_params ||= begin
        params.permit(*filtering_params, properties: available_properties.map(&:filter_param))
      end
    end

    def option_type_cache_key(option_type)
      filter_param = option_type.filter_param
      filtered_params = params[filter_param]

      [
        available_option_types_cache_key,
        filter_param,
        filtered_params
      ]
    end

    def available_option_types_cache_key
      @available_option_types_cache_key ||= [
        Spree::OptionType.filterable.maximum(:updated_at).to_f,
        products_for_filters_cache_key
      ].flatten.join('/')
    end

    def available_option_types
      @available_option_types ||= Rails.cache.fetch("available-option-types/#{available_option_types_cache_key}") do
        option_values = OptionValues::FindAvailable.new(products_scope: products_for_filters).execute
        Filters::OptionsPresenter.new(option_values_scope: option_values).to_a
      end
    end

    def available_properties_cache_key
      @available_properties_cache_key ||= [
        Spree::Property.filterable.maximum(:updated_at).to_f,
        products_for_filters_cache_key
      ].flatten.join('/')
    end

    def available_properties
      @available_properties ||= Rails.cache.fetch("available-properties/#{available_properties_cache_key}") do
        product_properties = ProductProperties::FindAvailable.new(products_scope: products_for_filters).execute
        Filters::PropertiesPresenter.new(product_properties_scope: product_properties).to_a.map do |property_presenter|
          CachedPropertyPresenter.new(
            property: property_presenter.send(:property),
            uniq_values: property_presenter.uniq_values)
        end
      end
    end

    def spree_social_link(service)
      return '' if current_store.send(service).blank?

      link_to "https://#{service}.com/#{current_store.send(service)}", target: '_blank', rel: 'nofollow noopener', 'aria-label': service do
        content_tag :figure, id: service, class: 'px-2' do
          icon(name: service, width: 22, height: 22)
        end
      end
    end

    def checkout_available_payment_methods
      @checkout_available_payment_methods ||= @order.available_payment_methods
    end

    def color_option_type_name
      @color_option_type_name ||= Spree::OptionType.color&.name
    end

    def country_flag_icon(country_iso_code = nil)
      return if country_iso_code.blank?

      content_tag :span, nil, class: "flag-icon flag-icon-#{country_iso_code.downcase}"
    end

    def product_wysiwyg_editor_enabled?
      defined?(Spree::Backend) && Spree::Backend::Config[:product_wysiwyg_editor_enabled]
    end

    def taxon_wysiwyg_editor_enabled?
      defined?(Spree::Backend) && Spree::Backend::Config[:taxon_wysiwyg_editor_enabled]
    end

    # converts line breaks in product description into <p> tags (for html display purposes)
    def product_description(product)
      description = if Spree::Frontend::Config[:show_raw_product_description] || product_wysiwyg_editor_enabled?
                      product.description
                    else
                      product.description.to_s.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>')
                    end
      description.blank? ? Spree.t(:product_has_no_description) : description
    end

    private

    def formatted_price(value)
      Spree::Money.new(value, currency: current_currency, no_cents_if_whole: true).to_s
    end

    def credit_card_icon(type)
      available_icons = %w[visa american_express diners_club discover jcb maestro master]

      if available_icons.include?(type)
        image_tag "credit_cards/icons/#{type}.svg", class: 'payment-sources-list-item-image'
      else
        image_tag 'credit_cards/icons/generic.svg', class: 'payment-sources-list-item-image'
      end
    end

    def checkout_edit_link(step = 'address', order = @order)
      return if order.uneditable?

      classes = 'align-text-bottom checkout-confirm-delivery-informations-link'

      link_to spree.checkout_state_path(step), class: classes, method: :get do
        inline_svg_tag 'edit.svg'
      end
    end

    def products_for_filters
      @products_for_filters ||= current_store.products.for_filters(current_currency, taxon: @taxon)
    end

    def products_for_filters_cache_key
      @products_for_filters_cache_key ||= begin
        [
          products_for_filters.maximum(:updated_at).to_f,
          base_cache_key,
          @taxon&.permalink
        ].flatten.compact
      end
    end
  end
end
