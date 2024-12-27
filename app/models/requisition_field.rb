class RequisitionField < ApplicationRecord
  belongs_to :requisition

  validates :name, presence: true
  validates :field_type, presence: true
  validates :value, presence: true

  enum field_type: {
    text: 0,
    number: 1,
    date: 2,
    boolean: 3
  }
end
