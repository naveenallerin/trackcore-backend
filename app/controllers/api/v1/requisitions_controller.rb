module Api
  module V1
    class RequisitionsController < ApplicationController
      before_action :set_requisition, only: [:show, :update, :destroy]
      
      def index
        @requisitions = Requisition.all
        render json: @requisitions, status: :ok
      end
      
      def show
        render json: @requisition, status: :ok
      end
      
      def create
        @requisition = Requisition.new(requisition_params)
        
        if @requisition.save
          render json: @requisition, status: :created
        else
          render json: { errors: @requisition.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        @requisition = Requisition.find(params[:id])
        
        if @requisition.update(requisition_params)
          render json: @requisition, status: :ok
        else
          render json: { errors: @requisition.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::StaleObjectError
        render json: {
          error: 'Concurrent update detected. Please refresh and try again.',
          code: 'STALE_OBJECT'
        }, status: :conflict
      end

      def destroy
        @requisition.destroy
        head :no_content
      end
      
      private
      
      def set_requisition
        @requisition = Requisition.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Requisition not found' }, status: :not_found
      end
      
      def requisition_params
        params.require(:requisition).permit(
          :title, 
          :department, 
          :status, 
          :salary_range,
          :lock_version  # Important: Include lock_version in permitted params
        )
      end
    end
  end
end
