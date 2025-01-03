class CreateRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :requisitions do |t|
      t.string :title, null: false
      t.string :department, null: false
      t.string :status, null: false, default: 'draft'
      t.string :salary_range
      t.integer :lock_version, default: 0, null: false

      t.timestamps
    end

    add_index :requisitions, :status
    add_index :requisitions, :department
  end
end
