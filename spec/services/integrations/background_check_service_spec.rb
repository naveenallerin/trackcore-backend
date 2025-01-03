require 'rails_helper'

RSpec.describe Integrations::BackgroundCheckService do
  let(:service) { described_class.new }
  let(:candidate) { OpenStruct.new(email: 'test@example.com') }

  describe '#request_check' do
    it 'returns a successful response with check details' do
      result = service.request_check(candidate)

      expect(result.success?).to be true
      expect(result.data[:check_id]).to be_present
      expect(result.data[:candidate_email]).to eq(candidate.email)
      expect(result.data[:status]).to eq('pending')
    end
  end
end
