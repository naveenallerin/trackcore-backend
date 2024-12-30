require 'rails_helper'

RSpec.describe Template, type: :model do
  # Basic validations
  subject { build(:template) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  # Add more specific tests based on your Template model requirements
end
