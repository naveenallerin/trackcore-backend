require 'rails_helper'

RSpec.describe ApprovalRequest, type: :model do
  describe 'associations' do
    it { should belong_to(:requisition) }
    it { should belong_to(:approval_workflow) }
    it { should belong_to(:approvable) }
    it { should belong_to(:approver) }
    it { should have_many(:approval_steps).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:approver) }
    it { should validate_presence_of(:requisition_id) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 'pending', approved: 'approved', rejected: 'rejected') }
  end

  describe 'status transitions' do
    let(:request) { create(:approval_request) }

    it 'can transition from pending to approved' do
      request.approve!
      expect(request).to be_approved
    end

    it 'can transition from pending to rejected' do
      request.reject!
      expect(request).to be_rejected
    end

    it 'updates status based on steps' do
      step = create(:approval_step, approval_request: request)
      step.approved!
      expect(request.reload).to be_approved
    end
  end
end
