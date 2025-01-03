class DripCampaignJob < ApplicationJob
  queue_as :default

  def perform(pipeline_id)
    pipeline = Pipeline.find(pipeline_id)
    pipeline.candidates.each do |candidate|
      Rails.logger.info "Sending drip email to #{candidate.email} for pipeline #{pipeline.name}"
    end
  end
end
