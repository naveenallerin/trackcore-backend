class RequisitionAttachment < ApplicationRecord
  belongs_to :requisition
  belongs_to :uploaded_by, class_name: 'User'
  
  has_one_attached :file
  
  validates :file, presence: true
  validates :file_name, presence: true
  
  before_validation :set_file_name, on: :create
  
  private
  
  def set_file_name
    self.file_name = file.filename if file.attached?
  end
end
