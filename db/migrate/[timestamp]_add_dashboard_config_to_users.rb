class AddDashboardConfigToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :dashboard_config, :jsonb, default: { widgets: [] }, null: false
  end
end
