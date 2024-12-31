class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :target, polymorphic: true, optional: true

  validates :message, presence: true
  
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  
  def mark_as_read!
    update!(read_at: Time.current)
  end
end
