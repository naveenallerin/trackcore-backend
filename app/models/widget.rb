class Widget < ApplicationRecord
  validates :name, presence: true
  validates :widget_type, presence: true
  validates :config, presence: true
  validates :description, presence: true
  validates :roles_allowed, presence: true
  validates :category, presence: true
  validate :endpoint_or_partial_present
  validate :roles_allowed_format

  scope :available_for, ->(user) {
    user.admin? ? all : where(role_restricted: false)
  }
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :marketplace_visible, -> { active.order(:category, :name) }
  scope :for_role, ->(role) { 
    where("? = ANY(roles_allowed) OR array_length(roles_allowed, 1) IS NULL", role)
  }

  def self.default_widgets_for(user)
    available_for(user).order(:widget_type)
  end
  
  def self.available_for(user)
    active.where("? = ANY(roles_allowed) OR array_length(roles_allowed, 1) IS NULL", user.role)
  end

  def self.available_in_marketplace(user)
    marketplace_visible.for_role(user.role)
  end

  def available_for?(user)
    return true if user.admin?
    !role_restricted?
  end

  private

  def endpoint_or_partial_present
    return if endpoint.present? || partial_name.present?
    errors.add(:base, "Either endpoint or partial_name must be present")
  end

  def roles_allowed_format
    return if roles_allowed.is_a?(Array) && roles_allowed.all? { |r| r.is_a?(String) }
    errors.add(:roles_allowed, "must be an array of strings")
  end
end
