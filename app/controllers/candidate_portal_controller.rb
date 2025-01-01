class CandidatePortalController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_candidate!

  def dashboard
    @applications = current_user.applications.recent
  end

  def schedule_interview
    @available_slots = InterviewSlot.available
    # TODO: Implement scheduling logic
  end

  private

  def ensure_candidate!
    unless current_user.candidate?
      redirect_to root_path, alert: 'Access denied'
    end
  end
end