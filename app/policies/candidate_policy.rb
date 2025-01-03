class CandidatePolicy < ApplicationPolicy
  def show?
    user == record
  end

  def update?
    user == record
  end

  def permitted_attributes
    if user == record
      [:first_name, :last_name, :email, :phone, :location, 
       :primary_skill, :resume, :current_password]
    else
      []
    end
  end

  def show_feedback?
    return true if user.is_a?(Recruiter) && user.active?
    user == record
  end

  alias_method :in_context_feedback?, :show_feedback?
end
