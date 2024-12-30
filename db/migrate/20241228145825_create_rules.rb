class CreateRules < ActiveRecord::Migration[7.0]
  def change
    create_table :rules do |t|
      t.string :condition_expression
      t.string :action
      t.integer :priority
      t.boolean :active

      t.timestamps
    end
  end
end
