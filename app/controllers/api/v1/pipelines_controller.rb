# ...existing code...

  def drip
    pipeline = Pipeline.find(params[:pipeline_id])
    DripCampaignJob.perform_later(pipeline.id)
    render json: { message: "Drip campaign triggered for pipeline #{pipeline.name}" }, status: :ok
  end

# ...existing code...
