class RecruiterMailer < ApplicationMailer
  def candidate_stage_notification(candidate, recruiter)
    @candidate = candidate
    @stage = candidate.pipeline_stage
    @recruiter = recruiter

    mail(
      to: @recruiter.email,
      subject: "Candidate #{@candidate.full_name} moved to #{@stage.name}"
    )
  end
end
