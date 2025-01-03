class AnalyticsService
  class << self
    def candidate_pipeline_metrics(start_date, end_date)
      candidates = Candidate.where(created_at: start_date..end_date)
      
      {
        total_applications: candidates.count,
        by_stage: candidates.group(:stage).count,
        stage_conversion_rates: calculate_conversion_rates(candidates),
        average_time_in_stages: calculate_stage_durations(candidates)
      }
    end

    def dei_summary
      total_records = DeiRecord.count.to_f

      {
        gender_distribution: calculate_percentage_breakdown(DeiRecord.group(:gender).count, total_records),
        ethnicity_distribution: calculate_percentage_breakdown(DeiRecord.group(:ethnicity).count, total_records),
        disability_status_distribution: calculate_percentage_breakdown(DeiRecord.group(:disability_status).count, total_records),
        veteran_status_distribution: calculate_percentage_breakdown(DeiRecord.group(:veteran_status).count, total_records)
      }
    end

    def time_to_fill(requisition_id = nil)
      base_scope = requisition_id ? Requisition.where(id: requisition_id) : Requisition
      filled_reqs = base_scope.where.not(filled_at: nil)

      {
        average_days: filled_reqs.average("EXTRACT(EPOCH FROM filled_at - created_at) / 86400")&.round(1) || 0,
        median_days: calculate_median_days_to_fill(filled_reqs),
        by_department: calculate_time_to_fill_by_department(filled_reqs)
      }
    end

    private

    def calculate_conversion_rates(candidates)
      stages = candidates.group(:stage).count
      total = candidates.count.to_f
      
      stages.transform_values { |count| ((count / total) * 100).round(1) }
    end

    def calculate_stage_durations(candidates)
      candidates.group(:stage).average(
        "EXTRACT(EPOCH FROM updated_at - created_at) / 86400"
      ).transform_values { |avg| avg&.round(1) || 0 }
    end

    def calculate_percentage_breakdown(grouped_data, total)
      return {} if total.zero?

      grouped_data.transform_values do |count|
        ((count / total) * 100).round(1)
      end
    end

    def calculate_median_days_to_fill(requisitions)
      days = requisitions
        .pluck(Arel.sql("EXTRACT(EPOCH FROM filled_at - created_at) / 86400"))
        .compact
        .sort

      return 0 if days.empty?

      mid = days.length / 2
      days.length.odd? ? days[mid] : ((days[mid-1] + days[mid]) / 2.0).round(1)
    end

    def calculate_time_to_fill_by_department(requisitions)
      requisitions
        .group(:department)
        .average("EXTRACT(EPOCH FROM filled_at - created_at) / 86400")
        .transform_values { |avg| avg&.round(1) || 0 }
    end
  end
end
