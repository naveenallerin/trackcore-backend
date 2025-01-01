require 'rails_helper'

RSpec.describe JobBoardPostingService do
  let(:requisition) { create(:requisition, status: 'approved') }
  let(:service) { described_class.new(requisition) }

  describe '#post_to_boards' do
    it 'posts to specified job boards' do
      result = service.post_to_boards(['indeed', 'linkedin'])
      expect(result).to be true
    end

    it 'returns false for non-approved requisitions' do
      requisition.update(status: 'draft')
      result = service.post_to_boards
      expect(result).to be false
    end
  end
end