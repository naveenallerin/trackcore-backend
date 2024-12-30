require 'rails_helper'

RSpec.describe ApprovalWorkflowService do
  let(:request) { create(:approval_request) }
  let(:service) { described_class.new(request) }
  
  describe '#approve_step' do
    let!(:step1) { create(:approval_step, approval_request: request, order_index: 1) }
    let!(:step2) { create(:approval_step, approval_request: request, order_index: 2) }

    context 'with valid approval' do
      it 'approves the current step' do
        service.approve_step(
          step_id: step1.id,
          approver_id: step1.approver_id
        )
        
        expect(step1.reload).to be_approved
        expect(step2.reload).to be_pending
      end

      it 'approves the request when final step is approved' do
        step1.approved!
        
        service.approve_step(
          step_id: step2.id,
          approver_id: step2.approver_id
        )
        
        expect(request.reload).to be_approved
      end
    end

    context 'with invalid approval' do
      it 'raises error for out of sequence approval' do
        expect {
          service.approve_step(
            step_id: step2.id,
            approver_id: step2.approver_id
          )
        }.to raise_error(ApprovalError::InvalidStep)
      end

      it 'raises error for invalid approver' do
        expect {
          service.approve_step(
            step_id: step1.id,
            approver_id: 'wrong_approver'
          )
        }.to raise_error(ApprovalError::UnauthorizedApprover)
      end
    end
  end

  describe '#reject_step' do
    let!(:step) { create(:approval_step, approval_request: request) }

    it 'rejects the step and request' do
      service.reject_step(
        step_id: step.id,
        approver_id: step.approver_id,
        reason: 'Budget issues'
      )

      expect(step.reload).to be_rejected
      expect(request.reload).to be_rejected
    end

    it 'requires rejection reason' do
      expect {
        service.reject_step(
          step_id: step.id,
          approver_id: step.approver_id,
          reason: ''
        )
      }.to raise_error(ArgumentError)
    end
  end
end
