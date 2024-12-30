module Api
  module V1
    class InterviewsController < ApplicationController
      before_action :authorize_video_access!, only: [:recording, :transcript]
      
      # ...existing code...

      def create
        @interview = Interview.new(interview_params)
        
        if @interview.save
          @interview.generate_video_link if @interview.video_provider?
          render json: @interview, status: :created
        else
          render json: { errors: @interview.errors }, status: :unprocessable_entity
        end
      end

      def recording
        @interview = Interview.find(params[:id])
        render json: { url: @interview.recording_url }
      end

      def transcript
        @interview = Interview.find(params[:id])
        render json: { transcript: @interview.transcript }
      end

      private

      def interview_params
        params.require(:interview).permit(
          :start_time, :end_time, :video_provider,
          :candidate_consent, :candidate_id, :interviewer_id
        )
      end

      def authorize_video_access!
        unless current_user.can_access_video_content?
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end
    end
  end
end
