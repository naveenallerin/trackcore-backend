require 'rails_helper'

RSpec.describe "Notes", type: :request do
  let(:user) { create(:user, role: :recruiter) }
  let(:candidate) { create(:candidate) }
  let(:valid_attributes) { { content: "Great communication skills" } }

  describe "GET /candidates/:candidate_id/notes" do
    it "returns unauthorized without token" do
      get candidate_notes_path(candidate)
      expect(response).to have_http_status(:unauthorized)
    end

    context "with valid token" do
      before { sign_in_user(user) }

      it "returns notes for candidate" do
        get candidate_notes_path(candidate)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /candidates/:candidate_id/notes" do
    context "with valid token" do
      before { sign_in_user(user) }

      it "creates a new note" do
        post candidate_notes_path(candidate), params: { note: valid_attributes }
        expect(response).to have_http_status(:created)
      end
    end
  end
end