Rails.application.config.after_initialize do
  Rails.application.config.spree_backend.actions[:product] = Spree::Admin::Actions::ProductDefaultActionsBuilder.new.build
end
