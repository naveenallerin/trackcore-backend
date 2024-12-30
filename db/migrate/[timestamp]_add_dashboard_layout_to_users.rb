class AddDashboardLayoutToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :dashboard_layout, :jsonb, default: [], null: false
    add_index :users, :dashboard_layout, using: :gin
  end
end
