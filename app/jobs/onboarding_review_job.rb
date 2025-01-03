class OnboardingReviewJob < ApplicationJob
    queue_as :high_priority

    def perform(submission_id)
        @submission = OnboardingSubmission.find(submission_id)
        @metrics = { started_at: Time.current }

        process_submission
        notify_hr
        create_audit_log
    rescue StandardError => e
        handle_error(e)
    ensure
        track_metrics
    end

    private

    def process_submission
        # Process sensitive data with encryption
        @submission.process_sensitive_data
        @submission.update!(status: 'reviewed')
    end

    def notify_hr
        HrMailer.onboarding_review_notification(@submission).deliver_now
    rescue StandardError => e
        # Backup notification through alternative channel
        SlackNotifier.alert("HR Notification Failed: Submission ##{@submission.id}")
        raise e
    end

    def create_audit_log
        AuditLog.create!(
            event: 'onboarding_review',
            resource_type: 'OnboardingSubmission',
            resource_id: @submission.id,
            changes: @submission.changes,
            user: 'system'
        )
    end

    def handle_error(error)
        ErrorTracker.capture_exception(error)
        @submission.update(status: 'error')
        raise error
    end

    def track_metrics
        @metrics[:completed_at] = Time.current
        @metrics[:duration] = @metrics[:completed_at] - @metrics[:started_at]
        MetricsCollector.record('onboarding_review', @metrics)
    end
end
