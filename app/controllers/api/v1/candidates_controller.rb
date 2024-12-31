module Api
  module V1
    class CandidatesController < Api::BaseController
      before_action :set_candidate, only: [:show, :update, :destroy]

      def index
        candidates = Candidate.filter(filter_params)
        render json: candidates
      end

      def show
        render json: @candidate
      end

      def create
        candidate = Candidate.new(candidate_params)
        if candidate.save
          render json: candidate, status: :created
        else
          render json: { errors: candidate.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @candidate.update(candidate_params)
          render json: @candidate
        else
          render json: { errors: @candidate.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @candidate.destroy
        head :no_content
      end

      def bulk_update
        result = Candidates::BulkUpdateCandidatesService.new(
          user: current_user,
          candidate_ids: params[:candidate_ids],
          new_status: params[:new_status]
        ).call

        if result[:success]
          render json: result, status: :ok
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end

      def knockout_check
        service = Candidates::KnockoutService.new(@candidate)
        result = service.evaluate

        render json: result, status: :ok
      rescue Candidates::KnockoutService::InvalidExpressionError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def override_score
        if @candidate.update(override_params)
          render json: @candidate
        else
          render json: { errors: @candidate.errors }, status: :unprocessable_entity
        end
      end

      def check_duplicates
        duplicates = Candidates::DuplicateCheckerService.new(@candidate)
                      .find_duplicates
        
        render json: { duplicates: duplicates }
      end

      def merge
        result = Candidates::MergeCandidatesService.new(
          master_id: params[:master_id],
          secondary_ids: params[:secondary_ids],
          user: current_user
        ).merge

        if result[:success]
          render json: result
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end

      def archive
        if @candidate.update(archived_at: Time.current)
          head :no_content
        else
          render json: { errors: @candidate.errors }, status: :unprocessable_entity
        end
      end

      def upload_resume
        candidate = Candidate.find(params[:id])
        
        if params[:resume].blank?
          render json: { error: 'Resume file is required' }, status: :unprocessable_entity
          return
        end

        if candidate.resume.attach(params[:resume])
          render json: candidate, status: :ok
        else
          render json: { error: 'Failed to upload resume' }, status: :unprocessable_entity
        end
      end

      private

      def set_candidate
        @candidate = Candidate.find(params[:id])
      end

      def candidate_params
        params.require(:candidate).permit(:first_name, :last_name, :email)
      end

      def override_params
        params.require(:candidate).permit(:overridden_score, :override_reason)
      end

      def filter_params
        params.permit(:query, :status, :location, :min_experience, :name, :start_date, :end_date)
      end
    end
  end
end