class CandidateMailer < ApplicationMailer
  def stage_change_notification(candidate)
    @candidate = candidate
    @stage = candidate.pipeline_stage
    @unsubscribe_token = candidate.generate_unsubscribe_token

    mail(
      to: @candidate.email,
      subject: "Your application status has been updated at #{Rails.application.config.company_name}"
    )
  end
end
