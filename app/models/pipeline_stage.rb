class PipelineStage < ApplicationRecord
  belongs_to :department, optional: true
  has_many :candidates
  
  validates :name, presence: true
  validates :position, presence: true
  validates :position, uniqueness: { scope: :department_id }
  validates :name, uniqueness: { scope: :department_id }
  
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc) }
  
  def next_stage
    PipelineStage.where(department_id: department_id)
                 .where('position > ?', position)
                 .ordered
                 .first
  end
  
  def previous_stage
    PipelineStage.where(department_id: department_id)
                 .where('position < ?', position)
                 .ordered
                 .last
  end
end
