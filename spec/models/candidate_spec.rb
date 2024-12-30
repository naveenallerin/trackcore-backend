# spec/models/candidate_spec.rb
require 'rails_helper'
require 'support/auth_helpers'

RSpec.describe Candidate, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      candidate = Candidate.new(
        first_name: 'Valid',
        last_name:  'User',
        email:      'valid@example.com'
      )
      expect(candidate).to be_valid
    end

    it 'is invalid without an email' do
      candidate = Candidate.new(
        first_name: 'NoEmail',
        last_name:  'User',
        email:      nil
      )
      expect(candidate).not_to be_valid
      expect(candidate.errors.full_messages).to include("Email can't be blank")
    end

    it 'is invalid without a first_name' do
      candidate = Candidate.new(
        first_name: nil,
        last_name:  'User',
        email:      'example@example.com'
      )
      expect(candidate).not_to be_valid
      expect(candidate.errors.full_messages).to include("First name can't be blank")
    end

    it 'is invalid without a last_name' do
      candidate = Candidate.new(
        first_name: 'First',
        last_name:  nil,
        email:      'some@example.com'
      )
      expect(candidate).not_to be_valid
      expect(candidate.errors.full_messages).to include("Last name can't be blank")
    end

    context 'when checking uniqueness of email' do
      it 'is invalid if another candidate has the same email' do
        Candidate.create!(
          first_name: 'Existing',
          last_name:  'Candidate',
          email:      'duplicate@example.com'
        )

        duplicate = Candidate.new(
          first_name: 'New',
          last_name:  'User',
          email:      'duplicate@example.com'
        )

        expect(duplicate).not_to be_valid
        expect(duplicate.errors.full_messages).to include('Email has already been taken')
      end
    end
  end

  describe '#full_name' do
    it 'returns the concatenation of first_name and last_name' do
      candidate = Candidate.new(
        first_name: 'Jane',
        last_name:  'Doe',
        email:      'jane@example.com'
      )

      expect(candidate.full_name).to eq('Jane Doe')
    end
  end
end

# spec/support/auth_helpers.rb
module AuthHelpers
  def generate_candidate_token(candidate)
    Candidates::AuthService.new(
      email: candidate.email,
      password: candidate.password
    ).authenticate
  end
end