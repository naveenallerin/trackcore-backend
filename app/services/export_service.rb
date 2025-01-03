require 'csv'
require 'axlsx'

class ExportService
  class << self
    def generate_csv(type, start_date = nil, end_date = nil)
      case type
      when 'pipeline'
        generate_pipeline_csv(start_date, end_date)
      when 'dei'
        generate_dei_csv
      when 'time_to_fill'
        generate_time_to_fill_csv(start_date, end_date)
      else
        raise ArgumentError, "Unknown export type: #{type}"
      end
    end

    def generate_xlsx(type, start_date = nil, end_date = nil)
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: type.titleize) do |sheet|
          data = send("generate_#{type}_data", start_date, end_date)
          sheet.add_row data[:headers]
          data[:rows].each { |row| sheet.add_row row }
        end
      end
    end

    private

    def generate_pipeline_data(start_date, end_date)
      candidates = Candidate.where(created_at: start_date..end_date)
      headers = ['ID', 'Stage', 'Days in Stage', 'Applied Date', 'Last Updated']
      rows = candidates.map do |c|
        [
          c.id,
          c.stage,
          ((Time.current - c.stage_entered_at) / 1.day).round(1),
          c.created_at,
          c.updated_at
        ]
      end
      { headers: headers, rows: rows }
    end

    def generate_dei_data(_start_date = nil, _end_date = nil)
      records = DeiRecord.includes(:candidate)
      headers = ['Candidate ID', 'Gender', 'Ethnicity', 'Disability Status', 'Veteran Status']
      rows = records.map do |r|
        [
          r.candidate_id,
          r.gender,
          r.ethnicity,
          r.disability_status,
          r.veteran_status
        ]
      end
      { headers: headers, rows: rows }
    end

    def generate_time_to_fill_data(start_date, end_date)
      reqs = Requisition.where(filled_at: start_date..end_date)
      headers = ['ID', 'Title', 'Department', 'Days to Fill', 'Created', 'Filled']
      rows = reqs.map do |r|
        [
          r.id,
          r.title,
          r.department,
          ((r.filled_at - r.created_at) / 1.day).round(1),
          r.created_at,
          r.filled_at
        ]
      end
      { headers: headers, rows: rows }
    end

    def generate_pipeline_csv(start_date, end_date)
      data = generate_pipeline_data(start_date, end_date)
      generate_csv_content(data[:headers], data[:rows])
    end

    def generate_dei_csv
      data = generate_dei_data
      generate_csv_content(data[:headers], data[:rows])
    end

    def generate_time_to_fill_csv(start_date, end_date)
      data = generate_time_to_fill_data(start_date, end_date)
      generate_csv_content(data[:headers], data[:rows])
    end

    def generate_csv_content(headers, rows)
      CSV.generate(headers: true) do |csv|
        csv << headers
        rows.each { |row| csv << row }
      end
    end
  end
end
