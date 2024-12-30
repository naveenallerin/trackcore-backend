# config/environments/test.rb

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = false

  # Usually caching is off in test:
  # config.action_controller.perform_caching = false

  # If you had mailers uncommented, you’d do:
  # config.action_mailer.delivery_method = :test

  config.active_support.deprecation = :stderr

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Ensure paths are properly set for test environment
  custom_paths = %w[
    app/services
    app/adapters
    app/connectors
    app/errors
    app/validators
    app/workers
  ]
  
  config.autoload_paths = custom_paths.map { |path| Rails.root.join(path).to_s }
  config.eager_load_paths = []  # Prevent eager loading in test

  # Prevent autoloading issues in test
  config.autoloader = :zeitwerk
  
  # Ensure paths are mutable in test
  config.before_initialize do |app|
    app.config.paths.instance_variable_get(:@hash).dup
  end

  # etc. (Adjust logging or debug flags if needed)
end
