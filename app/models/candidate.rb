class Candidate < ApplicationRecord
  has_many :notes
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true
  
  def full_name
    "#{first_name} #{last_name}".strip
  end
end
