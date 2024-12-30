class CreateHistoricalMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :historical_metrics do |t|
      t.string :metric_type
      t.float :value
      t.date :recorded_at
      t.jsonb :metadata
      t.references :department, foreign_key: true
      t.timestamps
      
      t.index [:metric_type, :recorded_at]
      t.index [:department_id, :recorded_at]
    end
  end
end
