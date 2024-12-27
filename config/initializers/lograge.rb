Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = ['ActionController::API']

  config.lograge.custom_options = lambda do |event|
    {
      time: Time.current,
      params: event.payload[:params].except(*['controller', 'action']),
      user_id: event.payload[:user_id],
      remote_ip: event.payload[:remote_ip]
    }
  end
end
