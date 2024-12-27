require 'rails_helper'

RSpec.describe Requisition, type: :model do
  it { should belong_to(:user) }
  it { should have_many(:approval_requests) }
  it { should validate_presence_of(:title) }
  
  describe 'status validation' do
    it 'should allow valid statuses' do
      requisition = build(:requisition)
      %w[pending approved rejected].each do |status|
        requisition.status = status
        expect(requisition).to be_valid
      end
    end
    
    it 'should not allow invalid statuses' do
      requisition = build(:requisition, status: 'invalid')
      expect(requisition).not_to be_valid
    end
  end
end
