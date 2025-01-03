require 'rails_helper'

RSpec.describe 'Requisition Workflow', type: :model do
  let(:user) { create(:user, role: 'hiring_manager') }
  let(:department) { create(:department, name: 'Engineering') }

  describe 'workflow transitions' do
    context 'when creating a new requisition' do
      let(:requisition) do
        create(:requisition,
          title: 'Senior Developer',
          department: department,
          user: user,
          salary_range: '90000'
        )
      end

      it 'starts in draft status' do
        expect(requisition.status).to eq('draft')
      end

      it 'transitions from draft to pending_approval' do
        expect {
          requisition.submit_for_approval!
        }.to change(requisition, :status).from('draft').to('pending_approval')
      end
    end

    context 'when salary requires finance approval' do
      let(:high_salary_requisition) do
        create(:requisition,
          title: 'VP Engineering',
          department: department,
          user: user,
          salary_range: '150000',
          status: 'pending_approval'
        )
      end

      it 'creates finance approval request during approval' do
        expect {
          high_salary_requisition.approve!
        }.to change(high_salary_requisition.approval_requests, :count).by(1)

        last_request = high_salary_requisition.approval_requests.last
        expect(last_request.approver_type).to eq('finance')
        expect(last_request.status).to eq('pending')
      end

      it 'logs finance approval requirement' do
        expect(Rails.logger).to receive(:info).with(
          /Requisition .* requires finance approval/
        )
        
        high_salary_requisition.approve!
      end

      it 'transitions to open status after approval' do
        expect {
          high_salary_requisition.approve!
        }.to change(high_salary_requisition, :status)
          .from('pending_approval')
          .to('open')
      end
    end
  end

  describe 'concurrency handling' do
    let!(:requisition) { create(:requisition, title: 'Original Title') }

    it 'prevents concurrent updates using optimistic locking' do
      # Simulate two users loading the same requisition
      requisition_user_1 = Requisition.find(requisition.id)
      requisition_user_2 = Requisition.find(requisition.id)

      # First user updates successfully
      expect(requisition_user_1.update(title: 'Updated by User 1')).to be true

      # Second user's update should fail
      expect {
        requisition_user_2.update!(title: 'Updated by User 2')
      }.to raise_error(ActiveRecord::StaleObjectError)
    end

    it 'tracks version history of changes' do
      expect {
        requisition.update!(title: 'New Title')
      }.to change(requisition.versions, :count).by(1)

      last_version = requisition.versions.last
      expect(last_version.event).to eq('update')
    end
  end

  describe 'complete workflow scenario' do
    let(:hiring_manager) { create(:user, role: 'hiring_manager') }
    let(:requisition) do
      create(:requisition,
        title: 'Full Stack Developer',
        department: department,
        user: hiring_manager,
        salary_range: '120000'
      )
    end

    it 'follows the complete requisition lifecycle' do
      # Step 1: Initial state is draft
      expect(requisition.status).to eq('draft')

      # Step 2: Submit for approval
      requisition.submit_for_approval!
      expect(requisition.status).to eq('pending_approval')

      # Step 3: Finance check during approval
      expect(Rails.logger).to receive(:info).with(/requires finance approval/)
      
      # Step 4: Approve the requisition
      requisition.approve!
      expect(requisition.status).to eq('open')
      expect(requisition.approval_requests)
        .to exist(approver_type: 'finance', status: 'pending')

      # Step 5: Close the requisition
      requisition.close!
      expect(requisition.status).to eq('closed')
      expect(requisition.closed_at).to be_present
    end
  end
end
