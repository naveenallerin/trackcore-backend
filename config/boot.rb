# config/boot.rb

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup'  # Set up gems listed in the Gemfile.
# If you’re using bootsnap (improves boot performance):
require 'bootsnap/setup' if File.exist?(File.expand_path('../config/application.rb', __dir__))
