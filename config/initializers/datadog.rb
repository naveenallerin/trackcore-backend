Datadog.configure do |c|
  c.env = Rails.env
  c.service = 'trackcore-backend'
  c.api_key = ENV['DATADOG_API_KEY']
  
  # Enable Rails integration
  c.use :rails, {
    service_name: 'trackcore-backend',
    analytics_enabled: true,
    request_queuing: true,
    controller_service: 'trackcore-backend-web'
  }
  
  # Enable Redis integration
  c.use :redis, service_name: 'trackcore-backend-redis'
  
  # Enable Sidekiq integration
  c.use :sidekiq, service_name: 'trackcore-backend-worker'
end
