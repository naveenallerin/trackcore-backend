class ApprovalRequest < ApplicationRecord
  belongs_to :requisition
  belongs_to :approver, class_name: 'User'
  
  validates :status, inclusion: { in: %w[pending approved rejected] }
  
  after_save :update_requisition_status
  
  private
  
  def update_requisition_status
    if status_changed? && (status == 'approved' || status == 'rejected')
      requisition.update(status: status)
    end
  end
end
