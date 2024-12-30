
require 'rails_helper'

RSpec.describe Resource, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:category) }
  end

  describe '#increment_version!' do
    let(:resource) { create(:resource) }

    it 'increments version and stores history' do
      expect {
        resource.increment_version!
      }.to change { resource.version }.by(1)
      
      expect(resource.version_history).to include(resource.version.to_s)
    end
  end

  describe '#revert_to_version!' do
    let(:resource) { create(:resource) }

    before do
      resource.update(title: 'New Title')
      resource.increment_version!
    end

    it 'reverts to previous version' do
      old_title = resource.version_history['1']['title']
      resource.revert_to_version!(1)
      
      expect(resource.title).to eq(old_title)
      expect(resource.version).to eq(1)
    end
  end
end
