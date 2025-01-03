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
      t.string :event_type, null: false
      t.string :actor_type
      t.bigint :actor_id
      t.string :resource_type
      t.bigint :resource_id
      t.jsonb :changes_json
      t.string :ip_address
      t.text :notes
      t.timestamps

      t.index [:actor_type, :actor_id]
      t.index [:resource_type, :resource_id]
      t.index :event_type
      t.index :created_at
    end
  end
end