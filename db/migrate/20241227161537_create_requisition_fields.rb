class CreateRequisitionFields < ActiveRecord::Migration[7.0]
  def change
    drop_table :requisition_fields, if_exists: true
    
    create_table :requisition_fields do |t|
      t.string :name
      t.string :field_type
      t.boolean :required, default: false
      t.text :options
      t.integer :position
      t.boolean :active, default: true
      t.bigint :requisition_type_id

      t.timestamps
    end

    add_index :requisition_fields, :requisition_type_id
  end
end
