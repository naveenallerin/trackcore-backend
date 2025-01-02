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
      message: @message,
      account_sid: Rails.application.credentials.dig(:twilio, :whatsapp, :account_sid),
      auth_token: Rails.application.credentials.dig(:twilio, :whatsapp, :auth_token),
      from_number: Rails.application.credentials.dig(:twilio, :whatsapp, :phone_number)
    )
  end

  def log_success(preference)
    Rails.logger.info(
      "[Outreach Success] " \
      "Candidate: #{@candidate.id} (#{@candidate.full_name}), " \
      "Channel: #{@channel}, " \
      "Destination: #{preference.phone_number || @candidate.email}, " \
      "Message Length: #{@message.length}, " \
      "Time: #{Time.current}"
    )

    # Track the outreach attempt in our metrics
    track_outreach_metrics(success: true)
  end

  def log_opted_out
    Rails.logger.info(
      "[Outreach Skipped] " \
      "Candidate: #{@candidate.id} (#{@candidate.full_name}), " \
      "Channel: #{@channel}, " \
      "Reason: Opted out or no preference found, " \
      "Time: #{Time.current}"
    )

    track_outreach_metrics(success: false, reason: 'opted_out')
  end

  def log_error(message)
    Rails.logger.error(
      "[Outreach Error] " \
      "Candidate: #{@candidate.id} (#{@candidate.full_name}), " \
      "Channel: #{@channel}, " \
      "Error: #{message}, " \
      "Time: #{Time.current}"
    )

    track_outreach_metrics(success: false, reason: 'error')
  end

  def track_outreach_metrics(success:, reason: nil)
    StatsD.increment(
      'outreach.attempt', 
      tags: [
        "channel:#{@channel}", 
        "success:#{success}", 
        "reason:#{reason}",
        "environment:#{Rails.env}"
      ]
    )
  end
end
