class InterviewsController < ApplicationController
  before_action :set_interview, only: [:show, :update, :destroy]

  def index
    @interviews = Interview.all
    render json: @interviews
  end

  def show
    render json: @interview
  end

  def create
    @interview = Interview.new(interview_params)
    if @interview.save
      render json: @interview, status: :created
    else
      render json: @interview.errors, status: :unprocessable_entity
    end
  end

  def update
    if @interview.update(interview_params)
      render json: @interview
    else
      render json: @interview.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @interview.destroy
    head :no_content
  end

  private

  def set_interview
    @interview = Interview.find(params[:id])
  end

  def interview_params
    params.require(:interview).permit(:candidate_id, :scheduled_at, :location, :interviewer_id)
  end
end
