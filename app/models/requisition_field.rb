class RequisitionField < ApplicationRecord
  belongs_to :requisition

  validates :field_name, presence: true
  validates :field_value, presence: true
end
