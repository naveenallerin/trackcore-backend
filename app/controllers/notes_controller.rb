class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candidate, only: [:index, :create]
  before_action :set_note, only: [:update, :destroy]
  before_action :authorize_note, only: [:update, :destroy]

  def index
    notes = @candidate.notes.includes(:user).order(created_at: :desc)
    render json: notes
  end

  def create
    note = @candidate.notes.build(note_params)
    note.user = current_user

    if note.save
      render json: note, status: :created
    else
      render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @note.update(note_params)
      render json: @note
    else
      render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    head :no_content
  end

  private

  def set_candidate
    @candidate = Candidate.find(params[:candidate_id])
  end

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:content)
  end

  def authorize_note
    unless current_user.admin? || @note.user_id == current_user.id
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  end
end
