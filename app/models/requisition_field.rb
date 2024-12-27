class RequisitionField < ApplicationRecord
  belongs_to :requisition
  
  validates :field_name, :field_type, presence: true
  validate :valid_field_type?

  private

  def valid_field_type?
    unless %w[string number date boolean].include?(field_type)
      errors.add(:field_type, "must be one of: string, number, date, boolean")
    end
  end
end
