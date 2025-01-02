require 'twilio-ruby'

class WhatsappDispatchService
  class DeliveryError < StandardError; end

  def self.send_message(to:, message:, account_sid: nil, auth_token: nil, from_number: nil)
    new(
      account_sid: account_sid,
      auth_token: auth_token,
      from_number: from_number
    ).send_message(to, message)
  end

  def initialize(account_sid: nil, auth_token: nil, from_number: nil)
    @account_sid = account_sid || Rails.application.credentials.dig(:twilio, :whatsapp, :account_sid)
    @auth_token = auth_token || Rails.application.credentials.dig(:twilio, :whatsapp, :auth_token)
    @from_number = from_number || Rails.application.credentials.dig(:twilio, :whatsapp, :phone_number)
  end

  def send_message(to, message)
    validate_inputs!(to, message)
    
    client.messages.create(
      from: "whatsapp:#{@from_number}",
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
    @client ||= Twilio::REST::Client.new(@account_sid, @auth_token)
  end

  def validate_inputs!(phone_number, message_body)
    raise DeliveryError, 'Phone number is required' if phone_number.blank?
    raise DeliveryError, 'Message body is required' if message_body.blank?
    raise DeliveryError, 'Message too long (max 1600 characters)' if message_body.length > 1600
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
