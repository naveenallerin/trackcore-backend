module Api
  module V1
    class RequisitionsController < ApplicationController
      before_action :set_requisition, except: [:index, :create]
      before_action :authorize_requisition
      
      def index
        @requisitions = Requisition.includes(:department, :requisition_fields)
          .by_status(params[:status])
          .by_department(params[:department_id])
          .search(params[:query])
          .page(params[:page])
        
        render json: @requisitions, each_serializer: RequisitionSerializer
      end
      
      def show
        render json: @requisition
      end
      
      def create
        authorize Requisition
        
        result = Requisitions::CreateService.new(
          requisition_params.merge(created_by: Current.user),
          Current.user
        ).execute
        
        if result.success?
          render json: result.data, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      rescue Pundit::NotAuthorizedError
        render json: { error: 'Unauthorized' }, status: :forbidden
      end
      
      def submit
        processor = RequisitionProcessor.new(@requisition)
        
        if processor.submit_for_approval
          render json: @requisition
        else
          render json: { error: 'Cannot submit requisition' }, status: :unprocessable_entity
        end
      end
      
      def update
        authorize @requisition
        
        if @requisition.update(requisition_params)
          render json: @requisition
        else
          render json: { errors: @requisition.errors }, status: :unprocessable_entity
        end
      end
      
      def approval_complete
        @requisition.with_lock do
          if params[:approved]
            @requisition.update!(status: :approved)
          else
            @requisition.update!(status: :rejected)
          end
        end
        
        head :ok
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      private
      
      def set_requisition
        @requisition = Requisition.find(params[:id])
      end
      
      def requisition_params
        params.require(:requisition).permit(
          :title, 
          :department_id, 
          :description,
          custom_fields: [:key, :value, :type]
        )
      end
      
      def authorize_requisition
        authorize @requisition if @requisition.present?
      rescue Pundit::NotAuthorizedError
        render json: { error: 'Unauthorized' }, status: :forbidden
      end
    end
  end
end
