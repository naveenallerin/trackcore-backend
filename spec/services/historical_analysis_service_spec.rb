require 'rails_helper'

RSpec.describe HistoricalAnalysisService do
  describe '#year_over_year_analysis' do
    let(:metric_type) { 'time_to_fill' }
    let(:service) { described_class.new(metric_type: metric_type, start_date: 2.years.ago, end_date: Date.current) }

    context 'with complete data' do
      before do
        create(:historical_metric, metric_type: metric_type, value: 30, recorded_at: 1.year.ago)
        create(:historical_metric, metric_type: metric_type, value: 25, recorded_at: Date.current)
      end

      it 'calculates year-over-year changes' do
        result = service.year_over_year_analysis
        expect(result.first[:percent_change]).to be_present
      end
    end

    context 'with missing data' do
      it 'handles missing years gracefully' do
        result = service.year_over_year_analysis
        expect(result).to be_empty
      end
    end
  end
end
