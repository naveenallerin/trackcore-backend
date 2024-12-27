class CreateRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :requisitions do |t|
      t.string :title, null: false
      t.string :department, null: false
      t.text :description
      t.json :metadata
      t.json :status_history
      t.string :status, default: 'draft'
      t.timestamps
    end

    add_index :requisitions, :department
    add_index :requisitions, :status
  end
end
