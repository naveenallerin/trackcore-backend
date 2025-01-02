require 'twilio-ruby'

class WhatsappDispatchService
  class DeliveryError < StandardError; end

  def self.send_message(to:, message:)
    new.send_message(to, message)
  end

  def send_message(to, message)
    validate_inputs!(to, message)
    
    client.messages.create(
      from: "whatsapp:#{sender_phone_number}",
      to: "whatsapp:#{normalize_phone_number(to)}",
      body: message
    )

    { success: true, message: 'WhatsApp message sent successfully' }
  rescue Twilio::REST::RestError => e
    handle_twilio_error(e)
  rescue StandardError => e
    handle_general_error(e)
  end

  private

  def client
    @client ||= Twilio::REST::Client.new(
      Rails.application.credentials.dig(:twilio, :whatsapp, :account_sid),
      Rails.application.credentials.dig(:twilio, :whatsapp, :auth_token)
    )
  end

  def sender_phone_number
    Rails.application.credentials.dig(:twilio, :whatsapp, :phone_number)
  end

  def validate_inputs!(phone_number, message)
    raise DeliveryError, 'Phone number is required' if phone_number.blank?
    raise DeliveryError, 'Message is required' if message.blank?
    raise DeliveryError, 'Message too long (max 1600 characters)' if message.length > 1600
  end

  def normalize_phone_number(phone_number)
    phone_number.gsub(/\D/, '')
  end

  def handle_twilio_error(error)
    { success: false, message: "Twilio error: #{error.message}" }
  end

  def handle_general_error(error)
    { success: false, message: "Error: #{error.message}" }
  end
end
