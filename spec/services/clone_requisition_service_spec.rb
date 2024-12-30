require 'rails_helper'

RSpec.describe CloneRequisitionService do
  describe '.clone' do
    let(:user) { create(:user) }
    let(:requisition) { create(:requisition, title: 'Original Requisition', user: user) }

    it 'creates a copy of the requisition' do
      cloned = CloneRequisitionService.clone(requisition)
      
      expect(cloned).to be_persisted
      expect(cloned.title).to eq("Copy of Original Requisition")
      expect(cloned.status).to eq('draft')
      expect(cloned.approval_state).to eq('pending')
    end

    context 'with custom fields' do
      before do
        create(:requisition_field, 
          requisition: requisition,
          field_name: 'experience',
          field_type: 'number',
          field_value: '5'
        )
      end

      it 'clones all custom fields' do
        cloned = CloneRequisitionService.clone(requisition)
        expect(cloned.requisition_fields.count).to eq(1)
        expect(cloned.requisition_fields.first.field_name).to eq('experience')
      end
    end

    context 'with job postings' do
      before do
        create(:job_posting, 
          requisition: requisition,
          board_name: 'linkedin',
          status: 'posted'
        )
      end

      it 'clones job postings as drafts' do
        cloned = CloneRequisitionService.clone(requisition)
        expect(cloned.job_postings.count).to eq(1)
        expect(cloned.job_postings.first.status).to eq('draft')
      end
    end

    context 'when cloning fails' do
      before do
        allow_any_instance_of(Requisition).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(requisition))
      end

      it 'raises a ServiceError' do
        expect {
          CloneRequisitionService.clone(requisition)
        }.to raise_error(ServiceError)
      end
    end
  end
end
