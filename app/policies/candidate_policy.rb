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
end
