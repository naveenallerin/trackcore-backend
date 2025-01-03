class AuditLog < ApplicationRecord
  validates :event_type, :occurred_at, presence: true
  
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :target, polymorphic: true, optional: true

  scope :recent, -> { order(occurred_at: :desc) }
  scope :by_event, ->(type) { where(event_type: type) }
end

class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.text :details
      t.timestamps
      
      t.index [:user_id, :created_at]
      t.index :action
    end
  end
end