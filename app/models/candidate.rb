class Candidate < ApplicationRecord
  belongs_to :requisition, optional: true
  has_many :notes
  has_many :interviews
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true
  validates :status, presence: true, inclusion: { in: %w[active inactive withdrawn hired] }
  
  def full_name
    "#{first_name} #{last_name}".strip
  end

  scope :active, -> { where(status: 'active') }
end
