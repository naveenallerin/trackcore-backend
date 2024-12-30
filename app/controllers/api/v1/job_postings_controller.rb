module Api
  module V1
    class JobPostingsController < ApplicationController
      def create
        service = PublishJobService.new(
          requisition_id: params[:requisition_id],
          board_name: params[:board_name]
        )

        if service.call
          render json: { status: 'success', message: 'Job successfully posted' }, status: :ok
        else
          render json: { status: 'error', message: service.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        service = PublishJobService.new(
          requisition_id: params[:id],
          board_name: params[:board_name]
        )

        if service.remove
          render json: { status: 'success', message: 'Job posting removed' }, status: :ok
        else
          render json: { status: 'error', message: service.errors }, status: :unprocessable_entity
        end
      end

      private

      rescue_from StandardError do |e|
        render json: { 
          status: 'error',
          message: 'An unexpected error occurred',
          details: e.message
        }, status: :internal_server_error
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: {
          status: 'error',
          message: 'Record not found',
          details: e.message
        }, status: :not_found
      end
    end
  end
end
