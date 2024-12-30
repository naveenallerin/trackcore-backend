require 'rails_helper'

RSpec.describe Postings::PublishJobService do
  let(:requisition) { create(:requisition, title: 'Software Engineer', description: 'Great job', location: 'Remote') }
  let(:board_name) { 'indeed' }
  let(:service) { described_class.new(requisition_id: requisition.id, board_name: board_name) }
  let(:mock_connector) { instance_double(Boards::IndeedConnector) }

  before do
    allow(Boards::ConnectorFactory).to receive(:build).with('indeed').and_return(mock_connector)
    allow(mock_connector).to receive(:post).and_return('external-123')
  end

  describe '#call' do
    it 'creates a job posting with posted status' do
      expect { service.call }.to change(JobPosting, :count).by(1)
      
      posting = JobPosting.last
      expect(posting.status).to eq('posted')
      expect(posting.board_name).to eq('indeed')
      expect(posting.external_reference_id).to eq('external-123')
    end

    context 'when the connector raises an error' do
      before do
        allow(mock_connector).to receive(:post).and_raise(StandardError, 'API Error')
      end

      it 'creates a job posting with failed status' do
        expect { service.call }.to change(JobPosting, :count).by(1)
        
        posting = JobPosting.last
        expect(posting.status).to eq('failed')
        expect(posting.board_name).to eq('indeed')
      end
    end
  end
end
