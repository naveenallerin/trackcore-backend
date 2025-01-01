class CreateBaseApprovalRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_requests do |t|
      # Polymorphic association for the requestor
      t.references :requestor, polymorphic: true, null: false
      
      # Request details
      t.string :status, null: false, default: 'pending'
      t.jsonb :data, null: false, default: {}
      t.text :reason

      # Approval details
      t.references :approver, polymorphic: true
      t.datetime :approved_at
      t.datetime :rejected_at

      t.timestamps
    end

    # Indexes for common queries
    add_index :approval_requests, :status
    add_index :approval_requests, [:approver_type, :approver_id]
    add_index :approval_requests, :approved_at
    add_index :approval_requests, :rejected_at
    
    # Add check constraint for valid status values
    add_check_constraint :approval_requests, 
      "status IN ('pending', 'approved', 'rejected')", 
      name: 'valid_approval_status'
  end
end
