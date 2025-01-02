
class EmailTemplatesController < ApplicationController
  # ...existing code...

  def request_ai_refinement
    template = EmailTemplate.find(params[:id])
    authorize template, :update?

    result = AiEmailRefinementService.refine_template(
      template.body,
      tone: params[:tone] || 'professional'
    )

    render json: {
      original: result[:original],
      refined: result[:refined],
      suggestions: result[:suggestions],
      template_id: template.id
    }
  rescue AiEmailRefinementService::AIServiceError => e
    render json: { error: e.message }, status: :service_unavailable
  end

  def apply_ai_refinement
    template = EmailTemplate.find(params[:id])
    authorize template, :update?

    template.create_version_and_update!(
      body: params[:refined_content],
      ai_refined_at: Time.current,
      ai_refinement_metadata: {
        suggestions: params[:suggestions],
        tone: params[:tone],
        approved_by: current_user.id,
        approved_at: Time.current
      }
    )

    render json: template
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors }, status: :unprocessable_entity
  end

  # ...existing code...
end
