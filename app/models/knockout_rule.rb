class KnockoutRule < ApplicationRecord
  # Constants for rule types
  RULE_TYPES = {
    experience: 'experience',
    education: 'education',
    skills: 'skills',
    location: 'location',
    custom: 'custom'
  }.freeze

  # Validations
  validates :name, presence: true
  validates :rule_expression, presence: true
  validates :priority, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :valid_rule_expression?

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_priority, -> { order(priority: :asc) }

  private

  def valid_rule_expression?
    return if rule_expression.blank?
    
    unless rule_expression.is_a?(Hash) && 
           rule_expression['type'].present? && 
           rule_expression['condition'].present?
      errors.add(:rule_expression, 'must contain type and condition keys')
      return
    end

    unless RULE_TYPES.values.include?(rule_expression['type'])
      errors.add(:rule_expression, 'contains invalid rule type')
    end

    validate_rule_condition
  end

  def validate_rule_condition
    condition = rule_expression['condition']
    operator = condition['operator']
    value = condition['value']

    unless operator.present? && value.present?
      errors.add(:rule_expression, 'condition must contain operator and value')
      return
    end

    case rule_expression['type']
    when RULE_TYPES[:experience]
      validate_numeric_condition(value)
    when RULE_TYPES[:skills]
      validate_array_condition(value)
    when RULE_TYPES[:education]
      validate_education_condition(value)
    end
  end

  def validate_numeric_condition(value)
    unless value.is_a?(Numeric)
      errors.add(:rule_expression, 'value must be numeric for experience rules')
    end
  end

  def validate_array_condition(value)
    unless value.is_a?(Array)
      errors.add(:rule_expression, 'value must be an array for skills rules')
    end
  end

  def validate_education_condition(value)
    unless value.is_a?(String) || value.is_a?(Array)
      errors.add(:rule_expression, 'value must be a string or array for education rules')
    end
  end
end
