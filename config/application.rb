# config/application.rb

require_relative "boot"

# Only require the frameworks we need
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"

# Future options:
# require "action_mailer/railtie"
# require "active_storage/engine"
# require "action_cable/engine"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

module TrackcoreBackend
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 7.0
    config.load_defaults 7.0

    # Configure API-only mode
    config.api_only = true

    # Basic settings
    config.time_zone = 'UTC'
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en]

    # Logging
    config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info').to_sym
    config.log_tags = [:request_id]

    # API Performance optimizations
    config.action_controller.perform_caching = true
    config.cache_store = :memory_store
    config.action_controller.default_protect_from_forgery = false
    config.action_controller.allow_forgery_protection = false

    # CORS configuration
    config.x.cors.allowed_origins = ENV.fetch('CORS_ALLOWED_ORIGINS', '*')
    config.x.cors.allowed_methods = %w[GET POST PUT PATCH DELETE OPTIONS]
  end
end
