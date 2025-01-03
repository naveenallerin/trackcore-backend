class DeiRecord < ApplicationRecord
  belongs_to :candidate

  # Enums for standardized values
  enum gender: {
    prefer_not_to_say: 'prefer_not_to_say',
    male: 'male',
    female: 'female',
    non_binary: 'non_binary',
    other: 'other'
  }

  enum ethnicity: {
    prefer_not_to_say: 'prefer_not_to_say',
    american_indian_or_alaska_native: 'american_indian_or_alaska_native',
    asian: 'asian',
    black_or_african_american: 'black_or_african_american',
    hispanic_or_latino: 'hispanic_or_latino',
    native_hawaiian_or_pacific_islander: 'native_hawaiian_or_pacific_islander',
    white: 'white',
    two_or_more_races: 'two_or_more_races',
    other: 'other'
  }

  enum disability_status: {
    prefer_not_to_say: 'prefer_not_to_say',
    no_disability: 'no_disability',
    has_disability: 'has_disability'
  }

  enum veteran_status: {
    prefer_not_to_say: 'prefer_not_to_say',
    not_veteran: 'not_veteran',
    protected_veteran: 'protected_veteran'
  }

  validates :candidate_id, presence: true
  validates :gender, inclusion: { in: genders.keys }, allow_nil: true
  validates :ethnicity, inclusion: { in: ethnicities.keys }, allow_nil: true
  validates :disability_status, inclusion: { in: disability_statuses.keys }, allow_nil: true
  validates :veteran_status, inclusion: { in: veteran_statuses.keys }, allow_nil: true

  # Scopes for common queries
  scope :with_gender, ->(gender) { where(gender: gender) }
  scope :with_ethnicity, ->(ethnicity) { where(ethnicity: ethnicity) }
  scope :with_disability_status, ->(status) { where(disability_status: status) }
  scope :with_veteran_status, ->(status) { where(veteran_status: status) }
end
