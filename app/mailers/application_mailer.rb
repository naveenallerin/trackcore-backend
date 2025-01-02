class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:sendgrid, :from_email)
  layout 'mailer'
  
  rescue_from StandardError do |exception|
    Rails.logger.error "Mailer Error: #{exception.class} - #{exception.message}"
    Honeybadger.notify(exception) if defined?(Honeybadger)
    raise
  end
end
