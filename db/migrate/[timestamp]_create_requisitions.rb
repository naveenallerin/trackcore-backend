class CreateRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :requisitions do |t|
      t.string :title, null: false
      t.text :description
      t.references :department, null: false, foreign_key: true
      t.integer :status, default: 0
      t.string :external_approval_id
      t.string :approval_service
      
      t.timestamps
    end

    add_index :requisitions, :status
    add_index :requisitions, :external_approval_id
  end
end
