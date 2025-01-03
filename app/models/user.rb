gem 'devise'
gem 'pundit'

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :role, presence: true

  has_many :notes
  belongs_to :department
  has_many :audit_logs, dependent: :destroy
  
  enum role: {
    basic: 0,
    recruiter: 1,
    hiring_manager: 2,
    admin: 3
  }

  ROLES = %w[admin manager recruiter staff].freeze
  
  validates :role, inclusion: { in: ROLES }, allow_nil: true

  # Default role on creation
  after_initialize :set_default_role, if: :new_record?
  after_database_authentication :log_successful_sign_in

  def generate_jwt
    payload = {
      user_id: id,
      exp: 2.weeks.from_now.to_i
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  scope :with_role, ->(role) { where(role: roles[role]) }

  def manager_or_admin?
    %w[manager admin].include?(role)
  end

  def log_activity(action, details = nil)
    audit_logs.create!(
      action: action,
      details: details,
      created_at: Time.current
    )
  end

  private

  def set_default_role
    self.role ||= :basic
  end

  def log_successful_sign_in
    log_activity('sign_in', 'User signed in successfully')
  end
end
