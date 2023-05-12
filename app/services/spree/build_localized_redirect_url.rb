require 'uri'

module Spree
  class BuildLocalizedRedirectUrl
    prepend Spree::ServiceModule::Base

    LOCALE_REGEX = /^\/([A-Za-z]{2})\/|^\/([A-Za-z]{2}-[A-Za-z]{2})\/|^\/([A-Za-z]{2})$|^\/([A-Za-z]{2}-[A-Za-z]{2})$/.freeze

    SUPPORTED_PATHS_REGEX = /\/(products|t\/|cart|checkout|addresses|content|pages|login|account|logout|signup|users)/.freeze

    PRODUCT_PATH_REGEX = /\/products\/(\S+)/.freeze
    TAXON_PATH_REGEX = /\/t\/(\S+)/.freeze

    # rubocop:disable Lint/UnusedMethodArgument
    def call(url:, locale:, default_locale: nil)
      run :initialize_url_object
      run :generate_new_path
      run :append_locale_param
      run :build_url
    end
    # rubocop:enable Lint/UnusedMethodArgument

    protected

    def initialize_url_object(url:, locale:, default_locale:)
      success(
        url: URI(url),
        locale: locale,
        default_locale: default_locale,
        default_locale_supplied: default_locale_supplied?(locale, default_locale)
      )
    end

    def generate_new_path(url:, locale:, default_locale:, default_locale_supplied:)
      unless supported_path?(url.path)
        return success(
          url: url,
          locale: locale,
          path: cleanup_path(url.path),
          default_locale_supplied: default_locale_supplied,
          locale_added_to_path: false
        )
      end


      locale_url_match = url.path.match(LOCALE_REGEX)
      previous_locale = locale_url_match ? locale_url_match[1] || default_locale : default_locale

      product_path_match = url.path.match(PRODUCT_PATH_REGEX)
      taxon_path_match = url.path.match(TAXON_PATH_REGEX)

      if product_path_match
        new_path = generate_product_path(product_path_match, previous_locale, locale, default_locale, default_locale_supplied)
      elsif url.path.match(TAXON_PATH_REGEX)
        new_path = generate_taxon_path(taxon_path_match, previous_locale, locale, default_locale, default_locale_supplied)
      else
        new_path = generate_regular_page_path(default_locale_supplied, url, locale)
      end

      success(
        url: url,
        locale: locale,
        path: cleanup_path(new_path),
        default_locale_supplied: default_locale_supplied,
        locale_added_to_path: true
      )
    end

    def append_locale_param(url:, locale:, path:, default_locale_supplied:, locale_added_to_path:)
      return success(url: url, path: path, query: url.query) if locale_added_to_path

      query_params = Rack::Utils.parse_nested_query(url.query)

      if default_locale_supplied
        query_params.delete('locale')
      else
        query_params.merge!('locale' => locale)
      end

      query_string = query_params.any? ? query_params.to_query : nil

      success(url: url, path: path, query: query_string)
    end

    def build_url(url:, path:, query:)
      localized_url = builder_class(url).build(host: url.host, port: url.port, path: path, query: query).to_s
      success(localized_url)
    end

    private

    def supported_path?(path)
      return true if path.blank? || path == '/' || maches_locale_regex?(path)

      path.match(SUPPORTED_PATHS_REGEX)
    end

    def maches_locale_regex?(path)
      path.match(LOCALE_REGEX)[0].gsub('/', '') if path.match(LOCALE_REGEX)
    end

    def default_locale_supplied?(locale, default_locale)
      default_locale.present? && default_locale.to_s == locale.to_s
    end

    def cleanup_path(path)
      path.chomp('/').gsub('//', '/')
    end

    def builder_class(url)
      url.scheme == 'http' ? URI::HTTP : URI::HTTPS
    end

    def generate_product_path(product_path_match, previous_locale, locale, default_locale, default_locale_supplied)
      product = Mobility.with_locale(previous_locale) { Spree::Product.friendly.find(product_path_match[1]) }
      new_slug = Mobility.with_locale(locale) { product.slug(fallbacks: default_locale) }
      new_path_slug = "/products/#{new_slug}"
      default_locale_supplied ? new_path_slug : "/#{locale}/#{new_path_slug}"
    end

    def generate_taxon_path(taxon_path_match, previous_locale, locale, default_locale, default_locale_supplied)
      taxon = Mobility.with_locale(previous_locale) { Spree::Taxon.friendly.find(taxon_path_match[1]) }
      new_slug = Mobility.with_locale(locale) { taxon.permalink(fallbacks: default_locale) }
      new_path_slug = "/t/#{new_slug}"
      default_locale_supplied ? new_path_slug : "/#{locale}/#{new_path_slug}"
    end

    def generate_regular_page_path(default_locale_supplied, url, locale)
      if default_locale_supplied
        maches_locale_regex?(url.path) ? url.path.gsub(LOCALE_REGEX, '/') : url.path
      else
        maches_locale_regex?(url.path) ? url.path.gsub(LOCALE_REGEX, "/#{locale}/") : "/#{locale}#{url.path}"
      end
    end
  end
end
