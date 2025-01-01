class CreateApprovalFlows < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_flows do |t|
      t.references :requisition, null: false, foreign_key: true
      t.string :role, null: false
      t.integer :status, default: 0
      t.decimal :condition_threshold, precision: 12, scale: 2
      t.text :notes
      t.json :metadata
      t.integer :sequence, null: false, default: 0
      
      t.timestamps
    end

    add_index :approval_flows, [:requisition_id, :role], unique: true
    add_index :approval_flows, [:requisition_id, :sequence]
  end
end
