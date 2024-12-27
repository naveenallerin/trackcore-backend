class CreateApprovalRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_requests do |t|
      t.references :requisition, foreign_key: true
      t.references :approver, foreign_key: { to_table: :users }
      t.string :status, default: 'pending'
      t.text :comments
      t.timestamps
    end
  end
end
