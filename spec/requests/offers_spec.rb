require 'rails_helper'

RSpec.describe "Offers", type: :request do
  let(:user) { create(:user) }
  let(:candidate) { create(:candidate) }
  let(:job) { create(:job) }
  let(:valid_attributes) {
    {
      salary: 75000,
      status: 'pending',
      candidate_id: candidate.id,
      job_id: job.id
    }
  }

  before { sign_in user }

  describe "GET /offers" do
    it "returns a successful response" do
      get offers_path
      expect(response).to be_successful
    end
  end

  describe "POST /offers" do
    it "creates a new offer" do
      expect {
        post offers_path, params: { offer: valid_attributes }
      }.to change(Offer, :count).by(1)
    end
  end

  describe "PUT /offers/:id" do
    let(:offer) { create(:offer) }

    it "updates the offer" do
      put offer_path(offer), params: { offer: { status: 'accepted' } }
      expect(offer.reload.status).to eq 'accepted'
    end
  end

  describe "DELETE /offers/:id" do
    let!(:offer) { create(:offer) }

    it "deletes the offer" do
      expect {
        delete offer_path(offer)
      }.to change(Offer, :count).by(-1)
    end
  end
end