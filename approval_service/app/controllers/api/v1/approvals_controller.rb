module Api
  module V1
    class ApprovalsController < ApplicationController
      # ...existing code...

      def complete
        approval = Approval.find(params[:id])
        
        if approval.mark_as_complete!
          render json: ApprovalSerializer.new(approval), status: :ok
        else
          render json: { errors: approval.errors }, status: :unprocessable_entity
        end
      end

      # ...existing code...

      private

      def approval_params
        params.require(:approval).permit(:status, :comments)
      end
    end
  end
end
