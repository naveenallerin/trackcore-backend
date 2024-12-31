require 'rails_helper'

RSpec.describe "Api::V1::Dashboard", type: :request do
  let(:user) { create(:user) }
  
  before do
    # Create test data
    create_list(:requisition, 3, status: :open)
    create_list(:requisition, 2, status: :closed)
    
    create_list(:application, 2, application_status: :applied)
    create_list(:application, 3, application_status: :screened)
    create(:application, application_status: :interviewed)
    create(:application, application_status: :offered)
    create(:application, application_status: :hired)
    create(:application, application_status: :rejected)
    
    # Authenticate
    sign_in user
  end

  describe "GET /api/v1/dashboard" do
    it "returns dashboard metrics" do
      get "/api/v1/dashboard"
      
      expect(response).to have_http_status(200)
      
      json = JSON.parse(response.body)
      
      expect(json["requisitions_open"]).to eq(3)
      expect(json["requisitions_closed"]).to eq(2)
      
      expect(json["candidate_counts"]).to eq({
        "applied" => 2,
        "screened" => 3,
        "interviewed" => 1,
        "offered" => 1,
        "hired" => 1,
        "rejected" => 1
      })
    end

    it "requires authentication" do
      sign_out user
      get "/api/v1/dashboard"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
