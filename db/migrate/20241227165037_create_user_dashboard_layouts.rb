class CreateUserDashboardLayouts < ActiveRecord::Migration[7.0]
  def change
    create_table :user_dashboard_layouts do |t|

      t.timestamps
    end
  end
end
