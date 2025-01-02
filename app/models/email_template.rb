class EmailTemplate < ApplicationRecord
  has_paper_trail
  
  validates :name, :subject, :body, presence: true
  validates :name, uniqueness: { scope: :department }
  validate :validate_placeholder_syntax
  validate :validate_compliance_requirements
  
  before_save :extract_required_placeholders
  
  def render(context = {})
    EmailTemplateRenderer.render(self, context)
  end
  
  private
  
  def validate_placeholder_syntax
    placeholders = body.scan(/\{\{([^}]+)\}\}/).flatten
    invalid = placeholders.reject { |p| p.match?(/^[a-z_][a-z0-9_]*$/) }
    
    if invalid.any?
      errors.add(:body, "contains invalid placeholders: #{invalid.join(', ')}")
    end
  end
  
  def extract_required_placeholders
    self.required_placeholders = body.scan(/\{\{([^}]+)\}\}/).flatten.uniq
  end
  
  def validate_compliance_requirements
    if compliance_approved && compliance_version.blank?
      errors.add(:compliance_version, "must be present when template is compliance approved")
    end
  end
  
  class MissingPlaceholderError < StandardError
    attr_reader :missing_placeholders
    
    def initialize(missing)
      @missing_placeholders = missing
      super("Missing required placeholders: #{missing.join(', ')}")
    end
  end
end
