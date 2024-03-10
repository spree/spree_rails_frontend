require_relative 'configuration'

module Spree
  module Frontend
    class Engine < ::Rails::Engine
      config.middleware.use 'Spree::Frontend::Middleware::SeoAssist'

      # Prevent XSS but allow text formatting
      config.action_view.sanitized_allowed_tags = %w(a b del em i ins mark p small strong sub sup)
      config.action_view.sanitized_allowed_attributes = %w(href)

      initializer "spree.frontend.assets" do |app|
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.precompile += %w[ spree_frontend_manifest ]
      end

      initializer 'spree.frontend.importmap', before: 'importmap' do |app|
        app.config.importmap.paths << root.join('config/importmap.rb')
        # https://github.com/rails/importmap-rails?tab=readme-ov-file#sweeping-the-cache-in-development-and-test
        app.config.importmap.cache_sweepers << root.join('app/javascript')
      end

      initializer 'spree.frontend.environment', before: :load_config_initializers do |_app|
        Spree::Frontend::Config = Spree::Frontend::Configuration.new
      end
    end
  end
end
