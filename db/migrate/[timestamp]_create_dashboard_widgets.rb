class CreateDashboardWidgets < ActiveRecord::Migration[7.0]
  def change
    create_table :dashboard_widgets do |t|
      t.string :name, null: false
      t.string :widget_type, null: false
      t.jsonb :configuration, default: {}
      t.string :roles, array: true, default: []
      t.boolean :enabled, default: true
      t.integer :position
      t.timestamps
    end

    add_index :dashboard_widgets, :roles, using: 'gin'
  end
end
