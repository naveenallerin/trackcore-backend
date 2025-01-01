require 'rails_helper'

RSpec.describe "Interviews", type: :request do
  let(:user) { create(:user) }
  let(:candidate) { create(:candidate) }
  let(:job) { create(:job) }
  let(:valid_attributes) {
    {
      date: 1.day.from_now,
      status: 'scheduled',
      candidate_id: candidate.id,
      job_id: job.id
    }
  }

  before { sign_in user }

  describe "GET /interviews" do
    it "returns a successful response" do
      get interviews_path
      expect(response).to be_successful
    end
  end

  describe "POST /interviews" do
    it "creates a new interview" do
      expect {
        post interviews_path, params: { interview: valid_attributes }
      }.to change(Interview, :count).by(1)
    end
  end

  describe "PUT /interviews/:id" do
    let(:interview) { create(:interview) }

    it "updates the interview" do
      put interview_path(interview), params: { interview: { status: 'completed' } }
      expect(interview.reload.status).to eq 'completed'
    end
  end

  describe "DELETE /interviews/:id" do
    let!(:interview) { create(:interview) }

    it "deletes the interview" do
      expect {
        delete interview_path(interview)
      }.to change(Interview, :count).by(-1)
    end
  end
end
