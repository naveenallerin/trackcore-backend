
require 'rails_helper'

RSpec.describe ApprovalStep, type: :model do
  describe 'associations' do
    it { should belong_to(:approval_request) }
  end

  describe 'validations' do
    subject { build(:approval_step) }
    
    it { should validate_presence_of(:approval_request_id) }
    it { should validate_presence_of(:step_name) }
    it { should validate_presence_of(:order_index) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:approver_id) }
    
    it do
      should validate_uniqueness_of(:order_index)
        .scoped_to(:approval_request_id)
    end
  end

  describe 'callbacks' do
    let(:step) { create(:approval_step) }

    it 'updates parent request status after save' do
      expect(step.approval_request).to receive(:update_status!)
      step.approved!
    end
  end
end
