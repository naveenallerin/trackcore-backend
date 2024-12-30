class CreateApprovalRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_requests do |t|
      t.references :requisition, null: false, foreign_key: true
      t.references :approval_workflow, null: false, foreign_key: true
      t.references :approver, null: false, foreign_key: { to_table: :users }
      t.references :approvable, polymorphic: true
      t.string :status, default: 'pending'
      t.text :comment
      t.datetime :approved_at
      t.datetime :rejected_at

      t.timestamps
    end
  end
end
