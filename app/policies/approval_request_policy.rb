class ApprovalRequestPolicy < ApplicationPolicy
  def show?
    user.present? && (user.admin? || record.requisition.department_id == user.department_id)
  end

  def approve?
    user.present? && user.can_approve_requisitions?
  end

  def reject?
    approve?
  end
end

