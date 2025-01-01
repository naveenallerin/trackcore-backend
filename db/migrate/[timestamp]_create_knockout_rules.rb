class CreateKnockoutRules < ActiveRecord::Migration[7.0]
  def change
    create_table :knockout_rules do |t|
      t.string :name, null: false
      t.jsonb :rule_expression, null: false, default: {}
      t.boolean :active, default: true, null: false
      t.string :description
      t.integer :priority, default: 0, null: false
      t.jsonb :metadata, default: {}
      t.timestamps

      t.index :active
      t.index :priority
      t.index :rule_expression, using: :gin
    end
  end
end
