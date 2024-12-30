class CreateApprovalRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_requests do |t|
      t.references :approval_workflow, null: false, foreign_key: true
      t.references :approvable, polymorphic: true, null: false
      t.string :status, default: 'pending'
      t.text :comment
      t.datetime :approved_at
      t.datetime :rejected_at
      
      t.timestamps
    end

    add_index :approval_requests, [:approvable_type, :approvable_id]
  end
end
