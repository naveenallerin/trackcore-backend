# config/application.rb

require_relative 'boot'

require "rails"
# Pick the frameworks you need
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module TrackcoreBackend
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true

    # Configure autoloading
    config.autoloader = :zeitwerk
    

    # Replace autoloading configuration with this
    initializer 'trackcore.autoload', before: :set_autoload_paths do |app|
      app.config.paths.add('app/services', eager_load: true, autoload: true)
      app.config.paths.add('app/adapters', eager_load: true, autoload: true)
      app.config.paths.add('app/connectors', eager_load: true, autoload: true)
      app.config.paths.add('app/errors', eager_load: true, autoload: true)
      app.config.paths.add('app/validators', eager_load: true, autoload: true)
      app.config.paths.add('app/workers', eager_load: true, autoload: true)
    end

    # Disable eager loading in test
    config.eager_load = Rails.env.production?
  end
end
