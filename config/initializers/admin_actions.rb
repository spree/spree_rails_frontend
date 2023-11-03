Rails.application.config.after_initialize do
  if Spree::Core::Engine.backend_available?
    action = ::Spree::Admin::Actions::ActionBuilder.new('preview', ->(resource) { "/products/#{resource.slug}" }).
              with_icon_key('view.svg').
              with_label_translation_key('admin.utilities.preview').
              with_id('adminPreviewProduct').
              with_target(:blank).
              with_data_attributes({ turbo: false }).
              build

    Rails.application.config.spree_backend.actions[:product].add(action)
    Rails.application.config.spree_backend.actions[:images].add(action)
    Rails.application.config.spree_backend.actions[:variants].add(action)
    Rails.application.config.spree_backend.actions[:prices].add(action)
    Rails.application.config.spree_backend.actions[:stock].add(action)
    Rails.application.config.spree_backend.actions[:product_properties].add(action)
  end
end
