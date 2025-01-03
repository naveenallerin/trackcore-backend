class DashboardPolicy < ApplicationPolicy
  def index?
    true # All authenticated users can see basic dashboard
  end

  def advanced_stats?
    user.manager_or_admin?
  end

  def department_metrics?
    user.role == 'manager'
  end
end

