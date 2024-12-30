class UpdateApprovalRequestsStructure < ActiveRecord::Migration[7.0]
  def change
    change_table :approval_requests do |t|
      # Add missing columns
      t.references :approval_workflow, null: false, foreign_key: true
      t.string :approvable_type
      t.bigint :approvable_id
      t.string :approver_type
      t.datetime :approved_at
      t.datetime :rejected_at
      
      # Rename comments to comment to match model
      t.rename :comments, :comment

      # Remove old foreign key constraints
      t.remove_foreign_key :requisitions
      t.remove_foreign_key :users
      
      # Remove old columns after data migration
      t.remove :requisition_id
      t.remove :external_id
    end

    # Add new indexes
    add_index :approval_requests, [:approvable_type, :approvable_id]
    add_index :approval_requests, [:approver_type, :approver_id]
  end
end
