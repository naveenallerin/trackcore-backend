require 'rails_helper'

RSpec.describe ApprovalEscalationService do
  describe '.process_escalations' do
    let!(:old_pending) do
      create(:requisition,
             approval_state: :pending,
             created_at: 3.days.ago)
    end
    
    let!(:recent_pending) do
      create(:requisition,
             approval_state: :pending,
             created_at: 1.hour.ago)
    end

    subject { described_class.process_escalations }

    it 'escalates old pending requisitions' do
      travel_to Time.current do
        expect { subject }
          .to change { old_pending.reload.approval_state }
          .from('pending')
          .to('escalated')
      end
    end

    it 'does not escalate recent pending requisitions' do
      travel_to Time.current do
        expect { subject }
          .not_to change { recent_pending.reload.approval_state }
      end
    end

    it 'sends escalation notifications' do
      expect {
        travel_to Time.current do
          subject
        end
      }.to have_enqueued_job(EscalationNotificationJob).exactly(1).times
    end
  end
end
