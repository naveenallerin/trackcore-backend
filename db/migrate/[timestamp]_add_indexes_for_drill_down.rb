class AddIndexesForDrillDown < ActiveRecord::Migration[7.0]
  def change
    add_index :candidates, [:status, :assigned_to_id]
    add_index :requisitions, [:status, :department_id]
    add_index :requisitions, [:status, :assigned_to_id]
  end
end
