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
  end
end
