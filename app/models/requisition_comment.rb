
class RequisitionComment < ApplicationRecord
  belongs_to :requisition
  belongs_to :user
  
  validates :content, presence: true
  
  default_scope { order(created_at: :desc) }
  
  def author_name
    user&.name || 'Unknown'
  end
end
