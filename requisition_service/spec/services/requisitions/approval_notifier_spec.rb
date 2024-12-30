require 'rails_helper'

RSpec.describe Requisitions::ApprovalNotifier do
  let(:approval_id) { 123 }
  let(:notifier) { described_class.new(approval_id) }

  describe '#mark_complete' do
    context 'when the request is successful' do
      before do
        stub_request(:patch, "#{described_class::APPROVAL_SERVICE_URL}/api/v1/approvals/#{approval_id}/complete")
          .to_return(
            status: 200,
            body: { id: approval_id, status: 'completed' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns a success response' do
        result = notifier.mark_complete
        expect(result.success?).to be true
        expect(result.data['status']).to eq('completed')
      end
    end

    context 'when the request fails' do
      before do
        stub_request(:patch, "#{described_class::APPROVAL_SERVICE_URL}/api/v1/approvals/#{approval_id}/complete")
          .to_return(
            status: 422,
            body: { errors: ['Invalid status transition'] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns an error response' do
        result = notifier.mark_complete
        expect(result.success?).to be false
        expect(result.error).to include('Invalid status transition')
      end
    end
  end
end
