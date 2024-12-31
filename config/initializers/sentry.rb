Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.5
  config.send_default_pii = true
  config.environment = Rails.env
  
  config.before_send = lambda do |event, hint|
    # Scrub sensitive data if needed
    if event.request && event.request.data
      event.request.data = event.request.data.except('password', 'token')
    end
    event
  end
end
