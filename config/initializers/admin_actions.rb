Rails.application.config.after_initialize do
  Rails.application.config.spree_backend.actions[:product] = Spree::Admin::Actions::ProductPreviewActionBuilder.new.build
  Rails.application.config.spree_backend.actions.include?(:images) ? (Rails.application.config.spree_backend.actions[:images].items << Spree::Admin::Actions::ProductPreviewActionBuilder.new.build.items).flatten! : Rails.application.config.spree_backend.actions[:images] = Spree::Admin::Actions::ProductPreviewActionBuilder.new.build
  Rails.application.config.spree_backend.actions[:prices] = Spree::Admin::Actions::ProductPreviewActionBuilder.new.build
  Rails.application.config.spree_backend.actions[:stock] = Spree::Admin::Actions::ProductPreviewActionBuilder.new.build
end
