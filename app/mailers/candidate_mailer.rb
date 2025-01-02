class CandidateMailer < ApplicationMailer
  default from: Rails.application.credentials.dig(:mail, :from_address)

  def stage_change_notification(candidate)
    @candidate = candidate
    @stage = candidate.pipeline_stage
    @unsubscribe_token = candidate.generate_unsubscribe_token

    mail(
      to: @candidate.email,
      subject: "Your application status has been updated at #{Rails.application.config.company_name}"
      )
  end

  def send_template(email_template, recipient_email, variables = {})
    @render_result = EmailTemplateRenderer.render(email_template, variables)
    
    # Add common variables for footer/tracking
    variables.reverse_merge!(
      unsubscribe_link: unsubscribe_url(email: recipient_email),
      company_name: Rails.configuration.company_name
    )
    
    mail(
      to: recipient_email,
      from: email_address_with_name(
        Rails.application.credentials.dig(:sendgrid, :from_email),
        Rails.application.credentials.dig(:sendgrid, :from_name)
      ),
      subject: @render_result.subject,
      body: @render_result.body,
      content_type: "text/html"
    )
  rescue EmailTemplateRenderer::MissingVariableError => e
    Rails.logger.error "Failed to send email template: #{e.message}"
    raise
  end

  def outreach_email(candidate, message)
    @candidate = candidate
    @message = message
    @unsubscribe_url = generate_unsubscribe_url(@candidate)

    mail(
      to: @candidate.email,
      subject: "Message from #{Rails.application.credentials.dig(:company, :name)} Recruiting"
    )
  end

  def deletion_request_confirmation(candidate)
    @candidate = candidate
    @deletion_date = 30.days.from_now.to_date

    mail(
      to: candidate.email,
      subject: 'Your Account Deletion Request Has Been Received'
    )
  end

  def deletion_completed(email:)
    mail(
      to: email,
      subject: 'Your Account Has Been Deleted',
      body: 'Your account and personal data have been successfully anonymized as requested.'
    )
  end

  private

  def unsubscribe_url(email:)
    token = generate_unsubscribe_token(email)
    url_helpers.unsubscribe_url(email: email, token: token)
  end

  def generate_unsubscribe_token(email)
    MessageVerifier.generate_token(
      purpose: :unsubscribe,
      expires_in: 1.year,
      email: email
    )
  end

  def generate_unsubscribe_url(candidate)
    token = candidate.generate_unsubscribe_token
    unsubscribe_candidate_url(token: token)
  end
end
