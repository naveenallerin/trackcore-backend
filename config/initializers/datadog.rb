require 'datadog/statsd'
require 'ddtrace'

Datadog.configure do |c|
  # Remove explicit StatsD configuration as it's not needed
  c.tracing.instrument :rails
  c.tracing.instrument :redis
  c.tracing.instrument :sidekiq
  c.tracing.instrument :pg

  # Service configuration
  c.service = 'trackcore-backend'
  c.env = Rails.env
  c.tags = {
    'env' => Rails.env,
    'service' => 'trackcore-backend'
  }

  # Only enable if Datadog API key is present
  if ENV['DATADOG_API_KEY'].present?
    c.api_key = ENV['DATADOG_API_KEY']
  else
    c.tracing.enabled = false
  end
end
