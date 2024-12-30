module Candidates
  class BulkUpdateCandidatesService
    def initialize(user:, candidate_ids:, new_status:)
      @user = user
      @candidate_ids = candidate_ids
      @new_status = new_status
      @successes = []
      @failures = []
    end

    def call
      return invalid_input_error unless valid_input?

      Candidate.transaction do
        process_candidates
        create_audit_log
      end

      {
        success: true,
        success_count: @successes.size,
        failure_count: @failures.size,
        failures: @failures
      }
    rescue StandardError => e
      { success: false, error: e.message }
    end

    private

    def valid_input?
      @candidate_ids.present? && @new_status.present?
    end

    def invalid_input_error
      { success: false, error: 'Invalid input parameters' }
    end

    def process_candidates
      Candidate.where(id: @candidate_ids).each do |candidate|
        begin
          old_status = candidate.status
          candidate.update!(status: @new_status)
          @successes << { id: candidate.id, old_status: old_status }
        rescue StandardError => e
          @failures << { id: candidate.id, error: e.message }
        end
      end
    end

    def create_audit_log
      AuditLog.create!(
        user: @user,
        action: 'bulk_update',
        old_status: @successes.map { |s| s[:old_status] }.uniq.join(','),
        new_status: @new_status,
        candidate_ids: @successes.map { |s| s[:id] }.join(',')
      )
    end
  end
end
