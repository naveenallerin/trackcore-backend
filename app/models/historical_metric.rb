class HistoricalMetric < ApplicationRecord
  belongs_to :department, optional: true
  
  METRIC_TYPES = %w[time_to_fill cost_per_hire pipeline_velocity].freeze
  
  validates :metric_type, inclusion: { in: METRIC_TYPES }
  validates :value, presence: true
  validates :recorded_at, presence: true
  
  scope :by_date_range, ->(start_date, end_date) { where(recorded_at: start_date..end_date) }
  scope :by_metric_type, ->(type) { where(metric_type: type) }
end
