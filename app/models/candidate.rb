class Candidate < ApplicationRecord
  belongs_to :requisition, optional: true
  has_many :notes
  has_many :interviews
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true, length: { minimum: 2 }
  validates :primary_skill, presence: true, unless: :draft?
  validates :location, presence: true, unless: :draft?
  validates :status, presence: true, inclusion: { in: %w[active inactive withdrawn hired] }
  
  def full_name
    "#{first_name} #{last_name}".strip
  end

  scope :active, -> { where(status: 'active') }

  # Search scopes
  scope :filter_by_keyword, ->(keyword) {
    return all if keyword.blank?
    where("resume_text ILIKE :term OR 
           first_name ILIKE :term OR 
           last_name ILIKE :term OR 
           primary_skill ILIKE :term",
           term: "%#{sanitize_sql_like(keyword)}%")
  }

  scope :by_location, ->(location) {
    return all if location.blank?
    where("location ILIKE ?", "%#{sanitize_sql_like(location)}%")
  }

  scope :by_skill, ->(skill) {
    return all if skill.blank?
    where("primary_skill ILIKE ?", "%#{sanitize_sql_like(skill)}%")
  }

  scope :search_full_text, ->(query) {
    return all if query.blank?
    
    where("to_tsvector('english', resume_text || ' ' || 
           first_name || ' ' || 
           last_name || ' ' || 
           COALESCE(primary_skill, '') || ' ' || 
           COALESCE(location, '')) @@ plainto_tsquery('english', ?)", 
           query)
  }

  # Combined search method
  def self.advanced_search(params)
    candidates = all

    candidates = candidates.filter_by_keyword(params[:keyword]) if params[:keyword].present?
    candidates = candidates.by_location(params[:location]) if params[:location].present?
    candidates = candidates.by_skill(params[:skill]) if params[:skill].present?
    candidates = candidates.search_full_text(params[:query]) if params[:query].present?

    candidates
  end

  def update_resume_text(text)
    update(resume_text: text)
    ResumeParsingJob.perform_async(id) if text_changed?
  end

  private

  def draft?
    status == 'draft'
  end
end
