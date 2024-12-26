# config/application.rb

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'

# If you eventually want mailers, uncomment:
# require 'action_mailer/railtie'

# If you want WebSockets, un-comment:
# require 'action_cable/engine'

Bundler.require(*Rails.groups)

module TrackcoreBackend
  class Application < Rails::Application
    config.load_defaults 7.2

    # API only: minimal middleware, no views/assets:
    config.api_only = true

    # Example: set time zone or locale:
    # config.time_zone = 'UTC'
    # config.i18n.default_locale = :en

    # Example generator overrides:
    # config.generators do |g|
    #   g.test_framework :rspec,
    #                    fixtures: true,
    #                    helper_specs: false,
    #                    routing_specs: false,
    #                    request_specs: false
    #   g.factory_bot suffix: 'factory'
    # end
  end
end
