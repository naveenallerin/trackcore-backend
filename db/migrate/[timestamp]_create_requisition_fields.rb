class CreateRequisitionFields < ActiveRecord::Migration[7.0]
  def change
    create_table :requisition_fields do |t|
      t.references :requisition, null: false, foreign_key: true
      t.string :field_name
      t.string :field_type
      t.text :field_value
      t.boolean :required, default: false
      t.timestamps
    end
  end
end
