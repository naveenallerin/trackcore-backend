class CreateRequisitionFields < ActiveRecord::Migration[7.0]
  def change
    create_table :requisition_fields do |t|
      t.references :requisition, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :field_type, null: false
      t.string :value
      
      t.timestamps
    end

    add_index :requisition_fields, [:requisition_id, :name], unique: true
  end
end