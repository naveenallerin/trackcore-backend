require 'rails_helper'

RSpec.describe AdaptiveApprovalService do
  let(:user) { create(:user) }
  let(:requisition) { create(:requisition, created_by: user, salary: 100_000) }
  
  describe '.create_approval_requests_for' do
    context 'with valid requisition' do
      it 'creates basic approval chain for normal salary' do
        requests = described_class.create_approval_requests_for(requisition)
        
        expect(requests.count).to eq(2)
        expect(requests.pluck(:approver_role)).to match_array(['finance_manager', 'hr_manager'])
      end

      it 'includes CFO for high salary' do
        requisition.update!(salary: 200_000)
        requests = described_class.create_approval_requests_for(requisition)
        
        expect(requests.count).to eq(3)
        expect(requests.pluck(:approver_role)).to match_array(['finance_manager', 'hr_manager', 'cfo'])
      end

      it 'sets correct due dates' do
        freeze_time do
          request = described_class.create_approval_requests_for(requisition).first
          expected_date = 3.business_days.from_now.end_of_day
          
          expect(request.due_at).to eq(expected_date)
        end
      end
    end

    context 'with invalid requisition' do
      it 'raises error for nil requisition' do
        expect { 
          described_class.create_approval_requests_for(nil) 
        }.to raise_error(ArgumentError, 'Requisition must be present')
      end

      it 'raises error for unpersisted requisition' do
        new_requisition = build(:requisition)
        expect { 
          described_class.create_approval_requests_for(new_requisition) 
        }.to raise_error(ArgumentError, 'Requisition must be persisted')
      end

      it 'raises error for missing salary' do
        requisition.salary = nil
        expect { 
          described_class.create_approval_requests_for(requisition) 
        }.to raise_error(ArgumentError, 'Salary must be present')
      end
    end
  end
end
