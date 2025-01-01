require 'rails_helper'

RSpec.describe ApprovalFlow, type: :model do
  describe 'validations' do
    it { should belong_to(:requisition) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:sequence) }
    it { should validate_inclusion_of(:role).in_array(ApprovalFlow::APPROVAL_ROLES) }
  end

  describe '#needs_approval?' do
    let(:requisition) { create(:requisition, salary: 100_000) }
    
    context 'when threshold is set' do
      let(:approval_flow) { create(:approval_flow, requisition: requisition, condition_threshold: 50_000) }
      
      it 'returns true when salary exceeds threshold' do
        expect(approval_flow.needs_approval?).to be true
      end
      
      it 'returns false when salary is below threshold' do
        requisition.update(salary: 40_000)
        expect(approval_flow.needs_approval?).to be false
      end
    end
    
    context 'when threshold is nil' do
      let(:approval_flow) { create(:approval_flow, requisition: requisition, condition_threshold: nil) }
      
      it 'always returns true' do
        expect(approval_flow.needs_approval?).to be true
      end
    end
  end
end
