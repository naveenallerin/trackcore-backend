# app/models/candidate.rb

class Candidate < ApplicationRecord
  # Validations
  validates :email,      presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true

  # Custom instance method: returns "FirstName LastName"
  def full_name
    "#{first_name} #{last_name}"
  end
end
