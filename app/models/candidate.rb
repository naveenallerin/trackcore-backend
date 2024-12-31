# app/models/candidate.rb

class Candidate < ApplicationRecord
  include PgSearch::Model
  
  belongs_to :job
  has_many :notes, dependent: :destroy
  has_many :interviews, dependent: :destroy
  has_one_attached :resume

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: { scope: :job_id }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true, inclusion: { in: %w[new screening interviewed offered hired rejected] }
  validates :name, presence: true

  enum status: {
    new: 'new',
    screening: 'screening',
    qualified: 'qualified',
    interview: 'interview',
    offer: 'offer',
    hired: 'hired',
    rejected: 'rejected'
  }

  # Scopes

  scope :by_score, -> { order(ai_score: :desc) }
  scope :qualified_candidates, -> { where(status: [:qualified, :interview, :offer]) }

  # Scopes for filtering
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_location, ->(location) { where(location: location) if location.present? }
  scope :by_experience, ->(years) { where('experience >= ?', years) if years.present? }
  scope :by_name, ->(term) { where('first_name ILIKE ? OR last_name ILIKE ?', "%#{term}%", "%#{term}%") if term.present? }
  scope :created_between, ->(start_date, end_date) { 
    where(created_at: start_date..end_date) if start_date.present? && end_date.present?
  }

  pg_search_scope :search_everything,
    against: {
      first_name: 'A',
      last_name: 'A',
      email: 'B',
      location: 'C'
    },
    using: {
      tsearch: { prefix: true },
      trigram: { threshold: 0.3 }
    }

  def self.filter(params)
    candidates = all
    candidates = candidates.search_everything(params[:query]) if params[:query].present?
    candidates = candidates.by_status(params[:status])
    candidates = candidates.by_location(params[:location])
    candidates = candidates.by_experience(params[:min_experience])
    candidates = candidates.by_name(params[:name])
    candidates = candidates.created_between(params[:start_date], params[:end_date])
    candidates
  end

  # Custom instance method: returns "FirstName LastName"
  def full_name
    "#{first_name} #{last_name}"
  end

  # Optional callback for AI processing
  after_create :process_ai_scoring

  private

  def process_ai_scoring
    # Placeholder for AI scoring logic
    # This would integrate with your AI service
  end
end
