class AddIndexesToApplications < ActiveRecord::Migration[7.0]
  def change
    add_index :applications, [:candidate_id, :requisition_id], unique: true
    add_index :requisitions, :status
  end
end
