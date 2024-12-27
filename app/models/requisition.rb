
class Requisition < ApplicationRecord
  has_many :requisition_fields, dependent: :destroy
  
  validates :title, presence: true
  validates :department, presence: true
  validates :status, inclusion: { in: %w[draft pending approved published closed] }

  scope :active, -> { where(status: ['approved', 'published']) }
  scope :by_department, ->(dept) { where(department: dept) }

  def publish!
    update!(
      status: 'published',
      published_at: Time.current
    )
  end
end