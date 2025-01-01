require 'rails_helper'

RSpec.describe Offer, type: :model do
  let(:offer) { build(:offer) }

  it 'is valid with valid attributes' do
    expect(offer).to be_valid
  end

  it 'is invalid without title' do
    offer.title = nil
    expect(offer).not_to be_valid
  end

  it 'is invalid without salary' do
    offer.salary = nil
    expect(offer).not_to be_valid
  end

  it 'is invalid with negative salary' do
    offer.salary = -1000
    expect(offer).not_to be_valid
  end

  it 'has pending status by default' do
    expect(offer.status).to eq('pending')
  end

  it 'can transition from pending to accepted' do
    offer.save!
    offer.accepted!
    expect(offer.reload.status).to eq('accepted')
  end

  it 'can transition from pending to rejected' do
    offer.save!
    offer.rejected!
    expect(offer.reload.status).to eq('rejected')
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:salary) }
  end

  describe 'associations' do
    it { should belong_to(:candidate) }
    it { should belong_to(:job) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values([:pending, :accepted, :rejected]) }
  end
end