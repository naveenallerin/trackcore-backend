module Api
  module V1
    class CandidateLicensesController < ApplicationController
      before_action :set_candidate_license, only: [:show, :update, :destroy, :verify]
      
      def index
        @licenses = CandidateLicense.all

        @licenses = @licenses.where(status: params[:status]) if params[:status].present?
        @licenses = @licenses.expiring_soon if params[:expiring] == 'true'

        render json: @licenses, 
               status: :ok, 
               each_serializer: CandidateLicenseSerializer
      end

      def show
        render json: @candidate_license, 
               serializer: CandidateLicenseSerializer
      end

      def create
        @candidate_license = CandidateLicense.new(candidate_license_params)

        if @candidate_license.save
          render json: @candidate_license, 
                 status: :created, 
                 serializer: CandidateLicenseSerializer
        else
          render json: { errors: @candidate_license.errors }, 
                 status: :unprocessable_entity
        end
      end

      def update
        if @candidate_license.update(candidate_license_params)
          render json: @candidate_license, 
                 serializer: CandidateLicenseSerializer
        else
          render json: { errors: @candidate_license.errors }, 
                 status: :unprocessable_entity
        end
      end

      def destroy
        @candidate_license.destroy
        head :no_content
      end

      def verify
        result = LicenseVerificationService.call(@candidate_license)

        if result.success?
          render json: { 
            message: 'License verification initiated successfully',
            verification_id: result.verification_id 
          }, status: :ok
        else
          render json: { 
            error: 'License verification failed', 
            details: result.errors 
          }, status: :unprocessable_entity
        end
      end

      def expiring
        @licenses = CandidateLicense.expiring_soon
        render json: @licenses, 
               status: :ok, 
               each_serializer: CandidateLicenseSerializer
      end

      private

      def set_candidate_license
        @candidate_license = CandidateLicense.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'License not found' }, status: :not_found
      end

      def candidate_license_params
        params.require(:candidate_license).permit(
          :candidate_id,
          :license_type_id,
          :license_number,
          :issuing_authority,
          :status,
          :issued_date,
          :expiration_date,
          :notes
        )
      end
    end
  end
end
