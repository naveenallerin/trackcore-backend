class KnockoutRule < ApplicationRecord
  RULE_TYPES = %w[hard_knockout soft_flag].freeze

  validates :rule_name, presence: true, uniqueness: true
  validates :condition_expression, presence: true
  validates :rule_type, presence: true, inclusion: { in: RULE_TYPES }

  scope :active, -> { where(active: true) }
end
