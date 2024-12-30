class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.string :old_status
      t.string :new_status
      t.text :candidate_ids
      t.timestamps
    end

    add_index :audit_logs, :action
  end
end
