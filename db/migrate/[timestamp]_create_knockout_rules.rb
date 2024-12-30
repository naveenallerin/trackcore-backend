class CreateKnockoutRules < ActiveRecord::Migration[7.0]
  def change
    create_table :knockout_rules do |t|
      t.string :rule_name, null: false
      t.text :condition_expression, null: false
      t.string :rule_type, null: false
      t.boolean :active, default: true
      t.timestamps
    end

    add_index :knockout_rules, :rule_name, unique: true
    add_index :knockout_rules, :active
  end
end
