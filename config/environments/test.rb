# config/environments/test.rb

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.cache_classes = true
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

  # etc. (Adjust logging or debug flags if needed)
end
