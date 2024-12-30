class AddDepartmentToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :department, foreign_key: true, index: true
    add_index :users, [:department_id, :role]
  end
end
