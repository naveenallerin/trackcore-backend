
class CreateRequisitionFields < ActiveRecord::Migration[7.0]
  def change
    create_table :requisition_fields do |t|
      t.references :requisition, null: false, foreign_key: true
      t.string :field_key, null: false
      t.text :field_value
      t.jsonb :conditions, default: {}
      t.boolean :required, default: false

      t.timestamps
    end

    add_index :requisition_fields, [:requisition_id, :field_key], unique: true
  end
end