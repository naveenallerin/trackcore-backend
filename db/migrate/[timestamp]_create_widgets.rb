class CreateWidgets < ActiveRecord::Migration[7.0]
  def change
    create_table :widgets do |t|
      t.string :name, null: false
      t.string :widget_type
      t.boolean :role_restricted, default: false
      t.jsonb :config, default: {}
      t.timestamps
    end

    add_index :widgets, :role_restricted
    add_index :widgets, :widget_type
  end
end
