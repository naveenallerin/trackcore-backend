class CreateApprovalRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_requests do |t|
      t.references :requisition, null: false, foreign_key: true
      t.string :status, default: 'pending'
      t.string :approver_type
      t.string :external_reference
      t.jsonb :metadata
      t.timestamps
    end
  end
end
