require 'rails_helper'

RSpec.describe Interview, type: :model do
  let(:interview) { build(:interview) }

  it 'is valid with valid attributes' do
    expect(interview).to be_valid
  end

  it 'is invalid without scheduled_at' do
    interview.scheduled_at = nil
    expect(interview).not_to be_valid
  end

  it 'is invalid without candidate' do
    interview.candidate = nil
    expect(interview).not_to be_valid
  end

  it 'can have an optional interviewer' do
    interview.interviewer = nil
    expect(interview).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:status) }
  end

  describe 'associations' do
    it { should belong_to(:candidate) }
    it { should belong_to(:job) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values([:scheduled, :completed, :cancelled]) }
  end
end