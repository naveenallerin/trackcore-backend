require 'rails_helper'
require 'webmock/rspec'

RSpec.describe "Requisition Workflow", type: :request do
  include ServiceMockHelpers

  before do
    mock_approval_service
    mock_job_posting_service
  end

  it "successfully completes the full requisition workflow" do
    # Step 1: Create requisition
    post "/api/v1/requisitions", params: {
      requisition: {
        title: "Senior Developer",
        department: "Engineering",
        location: "Remote"
      }
    }
    expect(response).to have_http_status(:created)
    requisition_id = JSON.parse(response.body)["data"]["id"]

    # Step 2: Verify approval was requested
    expect(WebMock).to have_requested(:post, "#{Requisitions::ApprovalNotifier::APPROVAL_SERVICE_URL}/api/v1/approvals")

    # Step 3: Complete approval
    approval_id = 1 # From mock
    patch "/api/v1/requisitions/#{requisition_id}/approve", params: {
      approval_id: approval_id
    }
    expect(response).to have_http_status(:ok)

    # Step 4: Verify job posting was created
    expect(WebMock).to have_requested(:post, "#{ENV['JOB_POSTING_SERVICE_URL']}/api/v1/postings")

    # Step 5: Verify final requisition state
    get "/api/v1/requisitions/#{requisition_id}"
    expect(response).to have_http_status(:ok)
    requisition = JSON.parse(response.body)["data"]
    expect(requisition["attributes"]["status"]).to eq("approved")
  end

  context "when approval service is down" do
    before do
      stub_request(:post, "#{Requisitions::ApprovalNotifier::APPROVAL_SERVICE_URL}/api/v1/approvals")
        .to_return(status: 503)
    end

    it "handles the error gracefully" do
      post "/api/v1/requisitions", params: {
        requisition: {
          title: "Senior Developer",
          department: "Engineering",
          location: "Remote"
        }
      }
      expect(response).to have_http_status(:service_unavailable)
      expect(JSON.parse(response.body)["errors"]).to include("Approval service unavailable")
    end
  end
end
