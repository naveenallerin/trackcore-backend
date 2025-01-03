module Api
  module V1
    class IntegrationsController < ApplicationController
      # ...existing code...

      def request_background_check
        candidate = Candidate.find(params[:candidate_id])
        service = Integrations::BackgroundCheckService.new
        
        result = service.request_check(candidate)

        if result.success?
          render json: result.data, status: :ok
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      # ...existing code...
    end
  end
end
