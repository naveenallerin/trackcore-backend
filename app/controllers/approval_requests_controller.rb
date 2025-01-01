class ApprovalRequestsController < ApplicationController
  before_action :set_approval_request, only: [:respond]

  def respond
    authorize @approval_request, :respond?

    if @approval_request.final?
      render_error("This approval has already been finalized", :unprocessable_entity)
      return
    end

    ActiveRecord::Base.transaction do
      @approval_request.update!(
        status: approval_params[:status],
        response_reason: approval_params[:reason],
        responded_at: Time.current,
        responder: current_user
      )

      if @approval_request.rejected?
        finalize_rejection
      elsif @approval_request.approved? && final_approval?
        finalize_approval
      end
    end

    render json: @approval_request, status: :ok
  rescue ArgumentError => e
    render_error(e.message, :unprocessable_entity)
  end

  private

  def set_approval_request
    @approval_request = ApprovalRequest.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Approval request not found", :not_found)
  end

  def approval_params
    params.require(:approval_request).permit(:status, :reason)
  end

  def final_approval?
    @approval_request.requisition.approval_requests.pending.none?
  end

  def finalize_rejection
    @approval_request.requisition.update!(
      status: 'rejected',
      completed_at: Time.current
    )
  end

  def finalize_approval
    @approval_request.requisition.update!(
      status: 'approved',
      completed_at: Time.current
    )
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end
end
