class RequisitionField < ApplicationRecord
  belongs_to :requisition
  
  validates :field_key, presence: true
  validates :field_value, presence: true
  validates :field_type, presence: true
  validate :value_matches_type
  
  enum field_type: {
    text: 0,
    number: 1,
    date: 2,
    boolean: 3
  }
  
  scope :active, -> { where(active: true) }
  
  private
  
  def value_matches_type
    case field_type
    when 'number'
      errors.add(:field_value, 'must be a number') unless field_value.to_f.to_s == field_value.to_s
    when 'date'
      errors.add(:field_value, 'must be a valid date') unless Date.parse(field_value) rescue true
    when 'boolean'
      errors.add(:field_value, 'must be true or false') unless ['true', 'false'].include?(field_value.downcase)
    end
  end
end
