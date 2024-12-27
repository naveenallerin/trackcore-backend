class Requisition < ApplicationRecord
  belongs_to :department
  has_many :requisition_fields, dependent: :destroy
  has_one :approval_request, dependent: :destroy
  has_many :status_changes, class_name: 'RequisitionStatusChange', dependent: :destroy
  has_many :comments, class_name: 'RequisitionComment', dependent: :destroy
  has_many :attachments, class_name: 'RequisitionAttachment', dependent: :destroy
  has_many :approval_steps, -> { order(sequence: :asc) }, dependent: :destroy
  has_many :approvers, through: :approval_steps
  has_many :job_postings, dependent: :destroy
  
  validates :title, presence: true
  validates :status, presence: true
  
  enum status: {
    draft: 0,
    pending_approval: 1,
    approved: 2,
    rejected: 3,
    closed: 4
  }
  
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_department, ->(dept_id) { where(department_id: dept_id) if dept_id.present? }
  
  before_update :track_status_change, if: :status_changed?
  after_touch :clear_cached_status
  after_update :publish_status_change_event, if: :saved_change_to_status?
  
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
end