class CreateRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :requisitions do |t|
      t.string :title, null: false
      t.text :description
      t.string :department
      t.string :location
      t.string :employment_type
      t.integer :status, default: 0
      t.jsonb :custom_fields, default: {}
      t.timestamps
      
      t.index :status
      t.index :department
      t.index [:title, :department, :location], name: 'idx_requisitions_search'
    end
  end
end
