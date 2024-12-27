# app/controllers/candidates_controller.rb
class CandidatesController < ApplicationController
  before_action :set_candidate, only: %i[show update destroy]

  # GET /candidates
  def index
    # Typically for an index, you don't need an instance variable.
    candidates = Candidate.order(created_at: :desc)
    render json: candidates
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

  def candidate_params
    params.require(:candidate)
          .permit(:first_name, :last_name, :email)
  end
end