
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
