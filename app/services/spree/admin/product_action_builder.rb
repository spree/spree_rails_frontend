module Spree
  module Admin
    class ProductActionBuilder
      class Root
        attr_reader :items

        def initialize
          @items = []
        end

        def add(item)
          raise KeyError, "Item with key #{item.name} already exists" if index_for_name(item.name)

          @items << item
        end

        private

        def index_for_name(name)
          @items.index { |e| e.name == name }
        end
      end

      class Action
        attr_reader :icon_name, :name, :classes, :text, :id, :target, :data

        def initialize(config)
          @icon_name =           config[:icon_name]
          @name =                config[:name] # to be renamed to 'key'
          @url =                 config[:url]
          @classes =             config[:classes]
          @availability_checks = []
          @text =                config[:text]
          @id =                  config[:id]
          @target =              config[:target]
          @data =                config[:data]
        end

        def available?(current_ability, resource = nil)
          return true if @availability_checks.empty?

          result = @availability_checks.map { |check| check.call(current_ability, resource) }

          result.all?(true)
        end

        def url(resource = nil)
          @url.is_a?(Proc) ? @url.call(resource) : @url
        end
      end

      def build
        root = Root.new
        action = Action.new(external_preview_config)
        root.add(action)
        root
      end

      private

      def external_preview_config
        {
          icon_name: 'view.svg',
          name: 'admin.utilities.preview', # to be renamed to 'key'
          url: ->(resource) { "/products/#{resource.name.gsub(" ","-").downcase}" },
          classes: 'btn-light',
          text: ::Spree.t('admin.utilities.preview', { name: :product }),
          id: 'adminPreviewProduct',
          target: :blank,
          data: { turbo: false }
        }
      end
    end
  end
end
