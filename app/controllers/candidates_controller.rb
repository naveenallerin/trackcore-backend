# app/controllers/candidates_controller.rb
class CandidatesController < ApplicationController
  include AdvancedSearchable
  include ActionController::Compression
  
  before_action :set_candidate, only: %i[show update destroy]
  before_action :check_rate_limit, only: %i[create update]
  
  # Configure compression
  before_action :compress_response
  
  # Rate limit configuration
  RATE_LIMIT = 100  # requests
  RATE_PERIOD = 1.hour

  # GET /candidates
  def index
    candidates = Candidate.includes(:skills, :experiences)
                        .order(created_at: :desc)
                        .search(search_params)
                        .filter_by_criteria(filter_params)
                        .score_candidates(ml_params)
    
    render json: candidates, each_serializer: CandidateSerializer
  end

  # GET /candidates/:id
  def show
    render json: @candidate
  end

  # POST /candidates
  def create
    candidate = Candidate.new(candidate_params)

    if candidate.save
      render json: candidate, status: :created
    else
      render json: { errors: candidate.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # PATCH/PUT /candidates/:id
  def update
    if @candidate.update(candidate_params)
      render json: @candidate
    else
      render json: { errors: @candidate.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE /candidates/:id
  def destroy
    @candidate.destroy
    head :no_content  # HTTP 204
  end

  private

  def set_candidate
    @candidate = Candidate.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Candidate not found' }, status: :not_found
  end

  def check_rate_limit
    key = "rate_limit:#{request.ip}"
    count = REDIS_CLIENT.incr(key)
    REDIS_CLIENT.expire(key, RATE_PERIOD.to_i) if count == 1

    if count > RATE_LIMIT
      render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
    end
  end

  def compress_response
    request.env['HTTP_ACCEPT_ENCODING'] = 'gzip'
  end

  def search_params
    params.permit(:query, :skills, :experience_level, :location)
  end

  def filter_params
    params.permit(
      :salary_range,
      :availability,
      :remote_only,
      skills: [],
      education_levels: [],
      years_of_experience: [:min, :max]
    )
  end

  def ml_params
    params.permit(
      :similarity_threshold,
      :experience_weight,
      :skill_match_weight,
      :education_weight
    )
  end

  def candidate_params
    params.require(:candidate)
          .permit(:first_name, :last_name, :email,
                 :experience_level, :location, :availability,
                 :remote_preference, :salary_expectation,
                 skills: [], education: [], experience: [])
  end
end