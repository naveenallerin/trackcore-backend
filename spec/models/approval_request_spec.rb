require 'rails_helper'

RSpec.describe ApprovalRequest, type: :model do
  let(:requisition) { create(:requisition) }
  let(:approval_request) { build(:approval_request, requisition: requisition) }

  describe 'validations' do
    it { should belong_to(:requisition) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending approved rejected]) }

    it 'cannot change status after approval' do
      approval_request.status = 'approved'
      approval_request.save!
      
      approval_request.status = 'rejected'
      expect(approval_request).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'notifies requisition on status change' do
      expect(requisition).to receive(:on_approval_status_change).with('approved')
      
      approval_request.status = 'approved'
      approval_request.save!
    end
  end
end
