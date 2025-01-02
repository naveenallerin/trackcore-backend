require 'twilio-ruby'

class SmsDispatchService
  class DeliveryError < StandardError; end

  def self.send_message(phone_number, message_body)
    new.send_message(phone_number, message_body)
  end

  def send_message(phone_number, message_body)
    validate_inputs!(phone_number, message_body)
    
    client.messages.create(
      from: sender_phone_number,
      to: normalize_phone_number(phone_number),
      body: message_body
    )

    { success: true, message: 'SMS sent successfully' }
  rescue Twilio::REST::RestError => e
    handle_twilio_error(e)
  rescue StandardError => e
    handle_general_error(e)
  end

  private

  def client
    @client ||= Twilio::REST::Client.new(
      Rails.application.credentials.dig(:twilio, :account_sid),
      Rails.application.credentials.dig(:twilio, :auth_token)
    )
  end

  def sender_phone_number
    Rails.application.credentials.dig(:twilio, :phone_number)
  end

  def validate_inputs!(phone_number, message_body)
    raise DeliveryError, 'Phone number is required' if phone_number.blank?
    raise DeliveryError, 'Message body is required' if message_body.blank?
    raise DeliveryError, 'Message too long (max 1600 characters)' if message_body.length > 1600
  end

  def normalize_phone_number(phone_number)
    # Remove any non-digit characters except leading +
    normalized = phone_number.gsub(/(?!\A\+)\D/, '')
    
    # Ensure number starts with + and country code
    return normalized if normalized.start_with?('+')
    "+1#{normalized}" # Default to US/Canada if no country code
  end

  def handle_twilio_error(error)
    error_message = case error.code
    when 21211
      'Invalid phone number'
    when 21606
      'Phone number is not currently reachable'
    when 21408
      'Message cannot be empty'
    when 21610
      'Message too long'
    else
      "SMS delivery failed: #{error.message}"
    end

    raise DeliveryError, error_message
  end

  def handle_general_error(error)
    raise DeliveryError, 'SMS delivery failed due to an unexpected error'
  end
end
