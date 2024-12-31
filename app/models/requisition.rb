class Requisition < ApplicationRecord
  belongs_to :department
  belongs_to :user
  belongs_to :template, optional: true
  has_many :requisition_fields, dependent: :destroy
  has_one :approval_request, dependent: :destroy
  has_many :status_changes, class_name: 'RequisitionStatusChange', dependent: :destroy
  has_many :comments, class_name: 'RequisitionComment', dependent: :destroy
  has_many :attachments, class_name: 'RequisitionAttachment', dependent: :destroy
  has_many :approval_steps, -> { order(sequence: :asc) }, dependent: :destroy
  has_many :approvers, through: :approval_steps
  has_many :job_postings, dependent: :destroy
  has_many :approval_requests, dependent: :destroy
  has_many :candidates
  has_many :workflow_steps
  has_many :applications
  has_many :candidates, through: :applications

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending approved rejected] }
  validates :description, presence: true
  validates :department, presence: true
  validates :approval_state, inclusion: { in: %w[pending approved rejected] }

  # Add JSON columns for flexible storage
  serialize :metadata, JSON
  serialize :status_history, JSON
  
  enum status: {
    draft: 0,
    pending_approval: 1,
    approved: 2,
    published: 3,
    closed: 4,
    cancelled: 5,
    open: 1
  }
  
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_department, ->(dept_id) { where(department_id: dept_id) if dept_id.present? }
  scope :pending_approval, -> { joins(:approval_request).where(approval_requests: { status: 'pending' }) }
  scope :approved, -> { joins(:approval_request).where(approval_requests: { status: 'approved' }) }
  scope :for_department, ->(department_id) { where(department_id: department_id) }
  scope :for_user, ->(user) {
    case user.role
    when 'Admin'
      all
    when 'Manager'
      where(department: user.department)
    when 'Recruiter'
      where(user_id: user.id)
    else
      none
    end
  }
  scope :pending, -> { where(status: 'pending') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :active, -> { where(status: [:pending_approval, :approved, :published]) }
  scope :pending_approval, -> { where(status: 'pending_approval') }
  scope :for_department, ->(department) { where(department: department) }
  scope :approved_in_month, ->(month) { where(status: 'approved').where('EXTRACT(MONTH FROM approved_at) = ?', month) }
  
  before_update :track_status_change, if: :status_changed?
  after_touch :clear_cached_status
  after_update :publish_status_change_event, if: :saved_change_to_status?
  after_update :schedule_job_board_posts, if: :should_auto_post?
  after_commit :invalidate_dashboard_cache

  DEFAULT_BOARDS = %w[indeed linkedin glassdoor].freeze
  
  def self.search(query)
    where("title ILIKE ?", "%#{query}%") if query.present?
  end
  
  def add_custom_field(key, value)
    requisition_fields.create!(
      field_key: key,
      field_value: value
    )
  end
  
  def can_transition_to?(new_status)
    case status
    when 'draft'
      ['pending_approval'].include?(new_status.to_s)
    when 'pending_approval'
      ['approved', 'rejected'].include?(new_status.to_s)
    when 'approved'
      ['closed'].include?(new_status.to_s)
    when 'rejected'
      ['draft'].include?(new_status.to_s)
    else
      false
    end
  end
  
  def current_approval_step
    approval_steps.find_by(status: 'pending')
  end
  
  def next_approver
    Rails.cache.fetch("#{cache_key_with_version}/next_approver") do
      current_approval_step&.approver
    end
  end
  
  def approval_progress
    completed = approval_steps.where(status: 'approved').count
    total = approval_steps.count
    {
      completed: completed,
      total: total,
      percentage: total.zero? ? 0 : (completed.to_f / total * 100).round
    }
  end
  
  def export_to_pdf
    RequisitionPdfExporter.new(self).generate
  end
  
  def publish_to_job_boards(boards)
    return false unless approved?
    
    boards.each do |board|
      job_postings.create!(board: board, status: :draft)
    end
    
    JobPostingWorker.perform_async(id)
    true
  end
  
  def external_approval?
    approval_service == 'external' && external_approval_id.present?
  end
  
  def sync_approval_status!
    return unless external_approval?
    
    status = ExternalApprovalService.check_status(external_approval_id)
    update!(status: status) if status != self.status
  end
  
  def request_approval(approver_type:)
    ApprovalService.new(self).request_approval(approver_type)
  end
  
  def complete_approval(approved)
    update(status: approved ? :approved : :rejected)
  end
  
  def on_approval_status_change(status)
    # Handle approval status changes
    update(status: status)
  end
  
  def current_approval_status
    latest_approval = approval_requests.order(created_at: :desc).first
    latest_approval&.status || 'pending'
  end

  accepts_nested_attributes_for :requisition_fields, allow_destroy: true

  def notify_status_change
    # Implement notification logic
  end

  def self.new_applications_count
    joins(:applications).where(applications: { status: 'new' }).distinct.count
  end

  def self.pending_interviews_count
    joins(:applications).where(applications: { status: 'interview_scheduled' }).distinct.count
  end

  def self.total_applicants_count
    joins(:applications).distinct.count
  end

  def self.offers_made_count
    joins(:applications).where(applications: { status: 'offer_sent' }).distinct.count
  end

  def self.offers_accepted_count
    joins(:applications).where(applications: { status: 'offer_accepted' }).distinct.count
  end

  def pending_approvals
    approval_steps.pending
  end

  def publish!
    update!(status: :published) if approved?
  end

  private
  
  def track_status_change
    return unless can_transition_to?(status)
    status_changes.create!(
      from_status: status_was,
      to_status: status,
      changed_by: Current.user&.id
    )
  end
  
  def clear_cached_status
    Rails.cache.delete("#{cache_key_with_version}/next_approver")
  end
  
  def publish_status_change_event
    EventPublisher.publish(
      'requisition.status_changed',
      {
        requisition_id: id,
        old_status: status_before_last_save,
        new_status: status,
        changed_by: Current.user&.id
      }
    )
  end

  def should_auto_post?
    saved_change_to_status? && status == 'approved' && 
      approval_request&.approved?
  end

  def schedule_job_board_posts
    PostRequisitionJob.perform_async(id, DEFAULT_BOARDS)
  end

  def invalidate_dashboard_cache
    Rails.cache.delete_matched("dashboard*")
  end

  after_initialize :set_default_status, if: :new_record?

  def set_default_status
    self.status ||= :draft
  end
end