require 'rails_helper'

RSpec.describe 'Approvals API', type: :request do
  let(:requisition) { create(:requisition, approval_state: :pending) }
  let(:valid_headers) { { 'Accept' => 'application/json' } }

  describe 'POST /api/v1/requisitions/:id/approve' do
    subject { post api_v1_requisition_approve_path(requisition), headers: valid_headers }

    context 'when the request is valid' do
      before do
        allow(ApprovalService).to receive(:initiate_approval).and_return(true)
      end

      it 'returns status code 200' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'initiates the approval process' do
        expect(ApprovalService).to receive(:initiate_approval).with(requisition)
        subject
      end
    end

    context 'when the request is invalid' do
      before do
        allow(ApprovalService).to receive(:initiate_approval)
          .and_raise(ApprovalService::Error.new("Invalid state transition"))
      end

      it 'returns status code 422' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /api/v1/requisitions/:id/approval_complete' do
    subject do
      patch api_v1_requisition_approval_complete_path(requisition),
            params: { approved: approved },
            headers: valid_headers
    end

    context 'when approved' do
      let(:approved) { true }

      it 'updates the requisition state to approved' do
        subject
        expect(response).to have_http_status(:ok)
        expect(requisition.reload.approval_state).to eq('approved')
      end

      it 'enqueues notification job' do
        expect {
          subject
        }.to have_enqueued_job(NotificationJob)
      end
    end

    context 'when rejected' do
      let(:approved) { false }

      it 'updates the requisition state to rejected' do
        subject
        expect(response).to have_http_status(:ok)
        expect(requisition.reload.approval_state).to eq('rejected')
      end
    end

    context 'when requisition not found' do
      subject do
        patch api_v1_requisition_approval_complete_path(0),
              params: { approved: true },
              headers: valid_headers
      end

      it 'returns 404' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
