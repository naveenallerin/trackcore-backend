# config/environment.rb

require_relative 'boot'

# Minimal frameworks if you're building an API-only Rails app.
# Adjust this if you do want mailers (action_mailer/railtie), websockets (action_cable/engine), etc.
require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
# require 'action_mailer/railtie'
# require 'action_cable/engine'
# If you need Active Storage or Action Text, uncomment:
# require 'active_storage/engine'
# require 'action_text/engine'

# Load all the gems in Gemfile
Bundler.require(*Rails.groups)

# Load application config from application.rb
require_relative 'application'

# Initialize the Rails application.
unless Rails.application.initialized?
  Rails.application.initialize!
end