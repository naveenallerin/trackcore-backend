class PipelineStageNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(candidate_id, previous_stage_id)
    candidate = Candidate.find_by(id: candidate_id)
    return unless candidate

    previous_stage = PipelineStage.find_by(id: previous_stage_id)
    current_stage = candidate.pipeline_stage

    # Notify candidate
    CandidateMailer.stage_change_notification(candidate).deliver_now

    # Notify recruiters for important stages
    if ['Interviewing', 'Offer'].include?(current_stage.name)
      Recruiter.active.each do |recruiter|
        RecruiterMailer.candidate_stage_notification(candidate, recruiter).deliver_later
      end
    end

    # Log the transition
    Rails.logger.info(
      "[Pipeline Stage Change] Candidate: #{candidate.full_name}, " \
      "From: #{previous_stage&.name || 'None'}, " \
      "To: #{current_stage.name}, " \
      "Time: #{Time.current}"
    )
  end
end
