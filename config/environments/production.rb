# config/environments/production.rb

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Code is not reloaded between requests.
  config.cache_classes = true
  config.eager_load = true

  # Full error reports are disabled for production.
  config.consider_all_requests_local = false

  # Enable caching in production if desired:
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    error_handler: -> (method:, returning:, exception:) {
      Rails.logger.error "Redis cache error: #{exception.message}"
    }
  }

  # Make sure log level is set appropriately (e.g. :info or :warn).
  config.log_level = :info
  config.log_tags  = [:request_id]

  # Structured logging configuration
  config.logger = ActiveSupport::Logger.new($stdout)
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    {
      time: Time.current,
      remote_ip: event.payload[:remote_ip],
      user_id: event.payload[:user_id],
      params: event.payload[:params].except('controller', 'action', 'format', 'id')
    }
  end

  # Mailers would only be set if you’d re-enable action_mailer in application.rb.
  # e.g.: config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.sendgrid.net',
    port: 587,
    domain: Rails.application.credentials.dig(:sendgrid, :domain),
    user_name: 'apikey',
    password: Rails.application.credentials.dig(:sendgrid, :api_key),
    authentication: :plain,
    enable_starttls_auto: true
  }

  config.action_mailer.default_url_options = {
    host: Rails.application.credentials.dig(:app_host),
    protocol: 'https'
  }

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  # You can serve static files from your app if you’re not using a separate server:
  # config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Active Storage configuration (if used)
  config.active_storage.service = :amazon

  # etc. as needed for DB pool, encryption, etc.
end
