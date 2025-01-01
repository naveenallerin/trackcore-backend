source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Core
gem 'rails', '~> 7.0.0'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'

# Auth & Authorization
gem 'devise', '~> 4.9.2'
gem 'devise-jwt'
gem 'pundit'
gem 'jwt', '~> 2.7'
gem 'bcrypt', '~> 3.1.7'

# API & Serialization
gem 'rack-cors'
gem 'graphql'
gem 'jsonapi-serializer'
gem 'active_model_serializers'
gem 'pagy', '~> 9.3.3'
gem 'pg_search', '~> 2.3'

# Background Processing
gem 'sidekiq'
gem 'redis'

# File Storage
gem 'aws-sdk-s3', '~> 1.86'

# Monitoring & Logging
gem 'elasticsearch'
gem 'lograge'

# Monitoring and Error Tracking
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'ddtrace'          # Datadog APM
gem 'dogstatsd-ruby'   # Datadog StatsD client
gem 'oj'              # Fast JSON parsing for lograge

# Security
gem 'secure_headers'

# Security & Encryption
gem 'lockbox'
gem 'blind_index'
gem 'rack-attack'

# Auditing & Security
gem 'paper_trail', '~> 16.0'
gem 'brakeman'
gem 'bundler-audit'
gem 'ruby_audit'

gem 'httparty'

group :development, :test do
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.0'
  gem 'pry-byebug'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'database_cleaner-active_record'
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rails-omakase', '~> 1.0'
  gem 'rubocop-minitest', '~> 0.36.0'
  gem 'rubocop-performance', '~> 1.23.0'
  gem 'webmock', '~> 3.19'
  gem 'vcr', '~> 6.1'
  gem 'dotenv-rails'
  gem 'rack-test'
end

gem "scout_apm", "~> 5.4"
gem "newrelic_rpm", "~> 9.16"
gem "aws-sdk-cloudwatch", "~> 1.108"
