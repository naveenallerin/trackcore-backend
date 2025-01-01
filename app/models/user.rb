gem 'devise'
gem 'pundit'

class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  has_many :notes
  
  enum role: {
    basic: 0,
    recruiter: 1,
    hiring_manager: 2,
    admin: 3
  }

  # Default role on creation
  after_initialize :set_default_role, if: :new_record?

  def generate_jwt
    payload = {
      user_id: id,
      exp: 2.weeks.from_now.to_i
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  private

  def set_default_role
    self.role ||= :basic
  end
end
