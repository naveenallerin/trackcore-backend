# config/boot.rb
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup'
require 'bootsnap/setup'  # <- this line ensures bootsnap is active
