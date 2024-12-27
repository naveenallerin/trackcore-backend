class RequisitionStatusChange < ApplicationRecord
  belongs_to :requisition
  belongs_to :changed_by, class_name: 'User', optional: true
  
  validates :from_status, :to_status, presence: true
  
  def status_changed_by
    changed_by&.name || 'System'
  end
end
