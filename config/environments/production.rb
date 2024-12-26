# config/environments/production.rb

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Code is not reloaded between requests.
  config.cache_classes = true
  config.eager_load = true

  # Full error reports are disabled for production.
  config.consider_all_requests_local = false

  # Enable caching in production if desired:
  # config.action_controller.perform_caching = true
  # config.cache_store = :mem_cache_store

  # Make sure log level is set appropriately (e.g. :info or :warn).
  config.log_level = :info
  config.log_tags  = [:request_id]

  # For container logs or aggregator logs, you may want:
  # config.logger = ActiveSupport::Logger.new(STDOUT)
  # config.logger.formatter = ::Logger::Formatter.new

  # Mailers would only be set if you’d re-enable action_mailer in application.rb.
  # e.g.: config.action_mailer.raise_delivery_errors = false

  # You can serve static files from your app if you’re not using a separate server:
  # config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # etc. as needed for DB pool, encryption, etc.
end
