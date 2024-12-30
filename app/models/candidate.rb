# app/models/candidate.rb

class Candidate < ApplicationRecord
  # Validations
  validates :first_name, presence: true

  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: %w[new screening interviewed offered hired rejected] }
  validates :name, presence: true

  # Custom instance method: returns "FirstName LastName"
  def full_name
    "#{first_name} #{last_name}"
  end
end
