# config/application.rb

require_relative "boot"
require "rails/all"
require "rack/contrib"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

module TrackcoreBackend
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 7.0
    config.load_defaults 7.0

    # Ensure paths are mutable
    config.before_configuration do
      config.eager_load_paths = config.eager_load_paths.dup
      config.autoload_paths = config.autoload_paths.dup
    end

    # Add custom paths
    config.eager_load_paths += [
      Rails.root.join('app/services'),
      Rails.root.join('app/services/candidates'),
      Rails.root.join('app/services/postings')
    ]

    config.autoload_paths += [
      Rails.root.join('app/services'),
      Rails.root.join('app/services/candidates'),
      Rails.root.join('app/services/postings')
    ]

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

    # Testing configuration
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: true
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    # Use Rails' built-in request ID middleware
    config.middleware.insert_before 0, Rack::Runtime
    
    # Configure middleware stack - do not use Rack::RequestId directly
    config.middleware.use ActionDispatch::RequestId
  end
end
