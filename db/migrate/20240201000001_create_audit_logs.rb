class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs do |t|
      t.string :event_type
      t.string :actor_type
      t.bigint :actor_id
      t.string :target_type
      t.bigint :target_id
      t.json :changes_made
      t.inet :ip_address
      t.datetime :occurred_at

      t.timestamps
    end

    add_index :audit_logs, [:actor_type, :actor_id]
    add_index :audit_logs, [:target_type, :target_id]
    add_index :audit_logs, :event_type
  end
end