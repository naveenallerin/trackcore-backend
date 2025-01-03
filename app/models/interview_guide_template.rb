class InterviewGuideTemplate < ApplicationRecord
    # Define valid interview types
    INTERVIEW_TYPES = %w[technical behavioral cultural].freeze

    # Validations
    validates :name, presence: true
    validates :interview_type, presence: true, inclusion: { in: INTERVIEW_TYPES }
    validates :seniority_level, presence: true

    # Scopes
    scope :by_type, ->(type) { where(interview_type: type) }
    scope :by_seniority, ->(level) { where(seniority_level: level) }

    # Helper method to find appropriate templates by type and seniority
    def self.find_by_type_and_seniority(type, level)
        by_type(type).by_seniority(level)
    end
end