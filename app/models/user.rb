class User < ApplicationRecord
  has_many :requisitions
  
  VALID_ROLES = %w[Recruiter Manager Admin Approver].freeze
  
  validates :email, presence: true, uniqueness: true
  validates :dashboard_config, presence: true
  validates_inclusion_of :dashboard_config, in: ->(user) { [{}] }, 
    if: -> { dashboard_config.blank? },
    message: "can't be blank"
  validates :role, presence: true, inclusion: { in: VALID_ROLES }
  validates :department, presence: true, if: -> { role == 'Manager' }
  
  has_one :dashboard_layout, class_name: 'UserDashboardLayout'
  after_create :create_default_dashboard_layout

  scope :recruiters, -> { where(role: 'Recruiter') }
  scope :managers, -> { where(role: 'Manager') }
  scope :by_department, ->(dept) { where(department: dept) }

  def approver?
    role == 'approver'
  end
  
  def add_widget(widget_key)
    widgets = dashboard_config["widgets"] || []
    return false if widgets.include?(widget_key)
    
    self.dashboard_config = dashboard_config.merge("widgets" => widgets + [widget_key])
    save
  end
  
  def remove_widget(widget_key)
    widgets = dashboard_config["widgets"] || []
    return false unless widgets.include?(widget_key)
    
    self.dashboard_config = dashboard_config.merge("widgets" => widgets - [widget_key])
    save
  end

  def available_widgets
    Widget.available_for_role(role)
  end

  def can_access_dashboard?
    VALID_ROLES.include?(role)
  end

  def can_view_requisition?(requisition)
    case role
    when 'Admin'
      true
    when 'Manager'
      requisition.department == department
    when 'Recruiter'
      requisition.user_id == id
    else
      false
    end
  end

  def can_view_candidate?(candidate)
    can_view_requisition?(candidate.requisition)
  end

  private

  def create_default_dashboard_layout
    default_widgets = Widget.available_for_role(role).keys.first(3)
    create_dashboard_layout(layout: { 'widgets' => default_widgets })
  end
end
