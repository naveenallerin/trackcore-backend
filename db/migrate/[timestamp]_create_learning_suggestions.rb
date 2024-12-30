class CreateLearningSuggestions < ActiveRecord::Migration[7.0]
  def change
    create_table :learning_suggestions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :resource_type
      t.string :skill_category
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :learning_suggestions, :skill_category
  end
end
