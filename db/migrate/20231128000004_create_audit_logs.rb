class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: true
      t.string :action
      t.string :resource_type
      t.bigint :resource_id
      t.json :changes
      t.timestamps
    end

    add_index :audit_logs, [:resource_type, :resource_id]
  end
end
