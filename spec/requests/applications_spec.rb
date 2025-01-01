require 'rails_helper'

RSpec.describe "Applications", type: :request do
  let(:json_headers) do
    {
      'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json'
    }
  end

  let!(:requisition) { create(:requisition) }
  let!(:candidate) { create(:candidate) }
  
  let(:valid_attributes) {
    {
      candidate_id: candidate.id,
      application_status: "pending",
      notes: "Initial application"
    }
  }

  let(:invalid_attributes) {
    {
      candidate_id: nil,
      application_status: "invalid_status"
    }
  }

  describe "POST /requisitions/:requisition_id/applications" do
    context "with valid parameters" do
      it "creates a new Application" do
        expect {
          post requisition_applications_path(requisition),
               params: { application: valid_attributes }.to_json,
               headers: json_headers
        }.to change(Application, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Application" do
        expect {
          post requisition_applications_path(requisition),
               params: { application: invalid_attributes }.to_json,
               headers: json_headers
        }.to change(Application, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /requisitions/:requisition_id/applications" do
    it "returns a successful response" do
      create(:application, requisition: requisition)
      get requisition_applications_path(requisition), headers: json_headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end
end