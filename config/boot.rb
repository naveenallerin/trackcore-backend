# config/boot.rb

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
require 'bundler/setup'  # Set up gems listed in the Gemfile
require 'bootsnap/setup' if File.exist?(File.expand_path('../bootsnap.rb', __dir__))
