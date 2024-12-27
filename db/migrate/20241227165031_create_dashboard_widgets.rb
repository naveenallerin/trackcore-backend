class CreateDashboardWidgets < ActiveRecord::Migration[7.0]
  def change
    create_table :dashboard_widgets do |t|

      t.timestamps
    end
  end
end
