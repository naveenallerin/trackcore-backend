class CreateHistoricalMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :historical_metrics do |t|

      t.timestamps
    end
  end
end
