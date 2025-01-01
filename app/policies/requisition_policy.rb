class RequisitionPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || user.recruiter? || record.user_id == user.id
  end

  def create?
    user.recruiter? || user.admin?
  end

  def update?
    user.admin? || record.user_id == user.id
  end

  def destroy?
    user.admin?
  end

  def initiate_approval?
    return true if user.admin?
    return true if record.created_by_id == user.id
    
    user.can_initiate_approvals? && record.department_id == user.department_id
  end

  def approve?
    return false unless user
    return true if user.admin?
    
    current_approval = record.current_approval_request
    current_approval&.approver_role == user.role
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
