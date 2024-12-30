require 'rails_helper'

RSpec.describe Candidates::BulkUpdateCandidatesService do
  let(:user) { create(:user) }
  let(:candidates) { create_list(:candidate, 3, status: 'Active') }
  let(:candidate_ids) { candidates.map(&:id) }
  let(:new_status) { 'Rejected' }

  subject do
    described_class.new(
      user: user,
      candidate_ids: candidate_ids,
      new_status: new_status
    ).call
  end

  describe '#call' do
    it 'updates all candidates successfully' do
      expect { subject }.to change { AuditLog.count }.by(1)
      
      expect(subject).to include(
        success: true,
        success_count: 3,
        failure_count: 0
      )

      candidates.each do |candidate|
        expect(candidate.reload.status).to eq('Rejected')
      end
    end

    context 'with invalid candidate ids' do
      let(:candidate_ids) { [-1, -2] }

      it 'handles non-existent candidates' do
        result = subject
        expect(result[:success]).to be true
        expect(result[:success_count]).to eq 0
        expect(result[:failure_count]).to eq 0
      end
    end
  end
end
