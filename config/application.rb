# config/application.rb

require_relative 'boot'

# Pick only the frameworks you want:
require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
# require 'action_mailer/railtie'
# require 'active_storage/engine'
# require 'action_cable/engine'
# require 'rails/test_unit/railtie'
# require 'sprockets/railtie' # for asset pipeline, not needed in API

Bundler.require(*Rails.groups)

module TrackcoreBackend
  class Application < Rails::Application
    config.load_defaults 7.2

    # API-only: no session/cookie middleware by default, minimal generators:
    config.api_only = true

    # Example of adjusting time zone, locale, etc.:
    # config.time_zone = 'UTC'
    # config.i18n.default_locale = :en

    # Example: configuring generators:
    # config.generators do |g|
    #   g.test_framework :rspec, fixtures: true
    #   g.factory_bot suffix: 'factory'
    # end
  end
end
