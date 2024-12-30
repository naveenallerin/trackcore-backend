class OfferTemplate < ApplicationRecord
  belongs_to :approved_by, class_name: 'User', optional: true
  has_many :offers
  
  validates :title, :body, presence: true
  validates :title, uniqueness: { scope: :version }
  validate :validate_placeholder_schema
  
  before_save :increment_version, if: :will_save_change_to_body?
  
  def approved?
    approved_by_id.present? && approved_at.present?
  end
  
  private
  
  def increment_version
    self.version = (self.class.where(title: title).maximum(:version) || 0) + 1
  end
  
  def validate_placeholder_schema
    required_placeholders = %w[candidate_name base_salary start_date]
    missing = required_placeholders - (placeholder_schema&.keys || [])
    errors.add(:placeholder_schema, "missing required placeholders: #{missing.join(', ')}") if missing.any?
  end
end
