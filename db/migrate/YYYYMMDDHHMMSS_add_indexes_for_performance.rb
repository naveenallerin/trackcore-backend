class AddIndexesForPerformance < ActiveRecord::Migration[7.0]
  def change
    add_index :candidates, :status
    add_index :candidates, :email
    add_index :applications, [:requisition_id, :candidate_id]
    
    # Add indexes for frequently searched columns
    add_index :requisitions, :status
    add_index :requisitions, :created_at
    add_index :candidates, :created_at
  end
end
