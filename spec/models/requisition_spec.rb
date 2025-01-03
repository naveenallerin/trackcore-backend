require 'rails_helper'

RSpec.describe Requisition, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:job_title) }
    it { should validate_presence_of(:department) }
    it { should validate_presence_of(:status) }
  end

  describe 'associations' do
    it { should belong_to(:department) }
    it { should belong_to(:user).optional }
    it { should have_many(:requisition_fields) }
    it { should have_many(:approval_steps) }
  end

  describe '#can_transition_to?' do
    let(:requisition) { create(:requisition, status: 'draft') }

    it 'allows transition from draft to pending_approval' do
      expect(requisition.can_transition_to?('pending_approval')).to be true
    end

    it 'prevents invalid transitions' do
      expect(requisition.can_transition_to?('closed')).to be false
    end
  end

  describe '#clone' do
    let(:requisition) { create(:requisition, :with_approval_steps) }

    it 'creates a new draft requisition' do
      cloned = RequisitionCloner.clone(requisition)
      expect(cloned).to be_persisted
      expect(cloned.status).to eq('draft')
      expect(cloned.approval_steps.count).to eq(requisition.approval_steps.count)
    end
  end

  describe 'finance approval checks' do
    let(:requisition) { create(:requisition, status: 'pending_approval', salary_range: '150000') }

    it 'creates finance approval request for high salary requisitions' do
      expect {
        requisition.approve!
      }.to change(requisition.approval_requests, :count).by(1)

      expect(requisition.approval_requests.last.approver_type).to eq('finance')
    end
  end

  describe 'concurrency handling' do
    let(:requisition) { create(:requisition) }

    it 'prevents concurrent updates' do
      requisition_1 = Requisition.find(requisition.id)
      requisition_2 = Requisition.find(requisition.id)

      requisition_1.update!(title: 'Updated First')
      
      expect {
        requisition_2.update!(title: 'Updated Second')
      }.to raise_error(ActiveRecord::StaleObjectError)
    end
  end
end
