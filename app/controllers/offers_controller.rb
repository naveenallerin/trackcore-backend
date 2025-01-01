class OffersController < ApplicationController
  before_action :set_offer, only: [:show, :update, :destroy, :accept, :reject]
  before_action :authorize_offer, except: [:index, :create]

  def index
    @offers = Offer.all
    render json: @offers
  end

  def show
    render json: @offer
  end

  def create
    @offer = Offer.new(offer_params)
    @offer.created_by = current_user

    if @offer.save
      render json: @offer, status: :created
    else
      render json: @offer.errors, status: :unprocessable_entity
    end
  end

  def update
    if @offer.update(offer_params)
      render json: @offer
    else
      render json: @offer.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @offer.destroy
    head :no_content
  end

  # Custom actions for offer status
  def accept
    if @offer.accepted!
      render json: @offer
    else
      render json: @offer.errors, status: :unprocessable_entity
    end
  end

  def reject
    if @offer.rejected!
      render json: @offer
    else
      render json: @offer.errors, status: :unprocessable_entity
    end
  end

  private

  def set_offer
    @offer = Offer.find(params[:id])
  end

  def offer_params
    params.require(:offer).permit(:candidate_id, :title, :salary, :status, :notes)
  end

  def authorize_offer
    authorize(@offer || Offer)
  end
end
