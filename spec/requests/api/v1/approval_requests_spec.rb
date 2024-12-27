
require 'rails_helper'

RSpec.describe 'Api::V1::ApprovalRequests', type: :request do
  let(:user) { create(:user, :approver) }
  let(:requisition) { create(:requisition) }
  let(:approval_request) { create(:approval_request, requisition: requisition) }

  before do
    sign_in user
  end

  describe 'POST /api/v1/approval_requests/:id/approve' do
    it 'approves the request' do
      post approve_api_v1_approval_request_path(approval_request)
      
      expect(response).to have_http_status(:success)
      expect(approval_request.reload.status).to eq('approved')
    end

    context 'when user is not authorized' do
      let(:user) { create(:user) }

      it 'returns forbidden status' do
        post approve_api_v1_approval_request_path(approval_request)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/approval_requests/:id/reject' do
    it 'rejects the request' do
      post reject_api_v1_approval_request_path(approval_request)
      
      expect(response).to have_http_status(:success)
      expect(approval_request.reload.status).to eq('rejected')
    end
  end
end
