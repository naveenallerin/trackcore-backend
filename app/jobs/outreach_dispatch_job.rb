class OutreachDispatchJob
  include Sidekiq::Job

  sidekiq_options queue: :outreach, retry: 3

  VALID_CHANNELS = %w[sms email whatsapp].freeze

  def perform(candidate_id, message_body, channel)
    @candidate = Candidate.find(candidate_id)
    @message = message_body
    @channel = channel.to_s.downcase

    validate_inputs!
    
    preference = find_communication_preference
    return log_opted_out unless preference&.opt_in?

    dispatch_message(preference)
    log_success(preference)

  rescue ActiveRecord::RecordNotFound => e
    log_error("Candidate not found: #{e.message}")
    raise
  rescue StandardError => e
    log_error("Failed to send #{@channel} message: #{e.message}")
    raise
  end

  private

  def validate_inputs!
    raise ArgumentError, "Invalid channel: #{@channel}" unless VALID_CHANNELS.include?(@channel)
    raise ArgumentError, "Message body cannot be blank" if @message.blank?
  end

  def find_communication_preference
    @candidate.communication_preferences.find_by(channel: @channel)
  end

  def dispatch_message(preference)
    case @channel
    when 'sms'
      dispatch_sms(preference.phone_number)
    when 'email'
      dispatch_email
    when 'whatsapp'
      dispatch_whatsapp(preference.phone_number)
    end
  end

  def dispatch_sms(phone_number)
    SmsDispatchService.send_message(phone_number, @message)
  end

  def dispatch_email
    CandidateMailer.outreach_email(@candidate, @message).deliver_now
  end

  def dispatch_whatsapp(phone_number)
    WhatsappDispatchService.send_message(
      to: phone_number,
      message: @message
    )
  end

  def log_success(preference)
    Rails.logger.info(
      "[Outreach Success] " \
      "Candidate: #{@candidate.id} (#{@candidate.full_name}), " \
      "Channel: #{@channel}, " \
      "Destination: #{preference.phone_number || @candidate.email}, " \
      "Time: #{Time.current}"
    )
  end

  def log_opted_out
    Rails.logger.info(
      "[Outreach Skipped] " \
      "Candidate: #{@candidate.id} (#{@candidate.full_name}), " \
      "Channel: #{@channel}, " \
      "Reason: Opted out"
    )
  end

  def log_error(message)
    Rails.logger.error(
      "[Outreach Error] " \
      "Candidate: #{@candidate.id} (#{@candidate.full_name}), " \
      "Channel: #{@channel}, " \
      "Error: #{message}"
    )
  end
end
