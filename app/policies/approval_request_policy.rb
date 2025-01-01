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

  def respond?
    return false unless user
    return true if user.admin?
    
    # Can respond if user has the approver role
    record.approver_role == user.role
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(approver_role: user.role)
      end
    end
  end
end

