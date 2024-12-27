# Gemfile
source 'https://rubygems.org'
ruby '3.2.2'

# Core Rails
gem 'rails', '~> 7.0.8'
gem 'pg'
gem 'puma'
gem 'bootsnap', require: false

# API & Security
gem 'rack-cors'
gem 'secure_headers'
gem 'jwt'

# Background Processing
gem 'redis'
gem 'sidekiq'

# Logging & Monitoring
gem 'lograge'
gem 'lograge-sql'
gem 'prometheus-client'
gem 'sentry-ruby'
gem 'sentry-rails'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers',  '~> 5.0'

  gem 'rubocop',           require: false
  gem 'rubocop-rails',     require: false
  gem 'brakeman'
  gem 'bundler-audit'
end

group :development do
  gem 'listen'
  gem 'spring'
  gem 'bullet'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'webmock'
end
