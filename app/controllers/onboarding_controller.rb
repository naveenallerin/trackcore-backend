class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :require_hr_admin
  before_action :set_candidate, only: [:start]

  def start
    workflow = OnboardingWorkflowService.new(@candidate)
    result = workflow.start_onboarding

    if result[:status] == 'success'
      render json: {
        message: 'Onboarding started successfully',
        data: result
      }, status: :ok
    else
      render json: {
        error: 'Failed to start onboarding',
        details: result[:message]
      }, status: :unprocessable_entity
    end
  end

  private

  def set_candidate
    @candidate = Candidate.find(params[:candidate_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Candidate not found' }, status: :not_found
  end

  def require_hr_admin
    unless current_user.hr_admin?
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  end
end
