require 'rails_helper'

RSpec.describe ApprovalService do
  let(:requisition) { create(:requisition) }
  let(:approver) { create(:user) }
  
  describe '.create_approval_request' do
    it 'creates a new approval request' do
      expect {
        described_class.create_approval_request(requisition, approver)
      }.to change(ApprovalRequest, :count).by(1)
    end
  end
  
  describe '.process_approval' do
    let(:approval_request) { create(:approval_request) }
    
    it 'updates approval request status' do
      described_class.process_approval(approval_request, 'approved', 'Approved!')
      expect(approval_request.reload.status).to eq('approved')
      expect(approval_request.requisition.status).to eq('approved')
    end
  end

  describe '#request_approval' do
    context 'with external approval service' do
      before do
        allow(Rails.configuration).to receive(:use_external_approval_service).and_return(true)
      end

      it 'creates external approval request' do
        service = described_class.new(requisition)
        external_adapter = instance_double(ExternalApprovalAdapter)
        allow(external_adapter).to receive(:create_approval_request)
          .and_return({ 'approval_id' => 'ext123' })
        
        service.instance_variable_set(:@external_adapter, external_adapter)
        service.request_approval
        
        expect(requisition.reload.external_approval_id).to eq('ext123')
        expect(requisition.status).to eq('pending_approval')
      end
    end
  end

  describe '#check_status' do
    context 'with external approval' do
      it 'checks external approval status' do
        requisition.update(external_approval_id: 'ext123')
        service = described_class.new(requisition)
        external_adapter = instance_double(ExternalApprovalAdapter)
        
        allow(external_adapter).to receive(:check_status)
          .with('ext123')
          .and_return({ 'status' => 'APPROVED' })
        
        service.instance_variable_set(:@external_adapter, external_adapter)
        service.check_status
        
        expect(requisition.reload.status).to eq('approved')
      end
    end
  end
end
