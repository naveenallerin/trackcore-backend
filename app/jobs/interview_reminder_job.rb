# /Users/allerintech/trackcore-backend/app/jobs/interview_reminder_job.rb

class InterviewReminderJob
    include Sidekiq::Job

    def perform
        upcoming_interviews.each do |interview|
            candidate = interview.candidate
            next unless candidate_needs_reminder?(candidate, interview)

            begin
                send_reminder(candidate, interview)
                track_reminder_status(candidate, interview, 'success')
            rescue StandardError => e
                handle_error(candidate, interview, e)
                track_reminder_status(candidate, interview, 'failure')
            end
        end

        log_statistics
    end

    private

    def upcoming_interviews
        # Fetch interviews that need reminders based on configurable timing thresholds
        Interview.where('scheduled_at >= ? AND scheduled_at <= ?', Time.now, Time.now + reminder_threshold)
    end

    def candidate_needs_reminder?(candidate, interview)
        # Check candidate communication preferences and if they need a reminder
        candidate.prefers_reminder? && !interview.reminder_sent?
    end

    def send_reminder(candidate, interview)
        # Send reminder via preferred channel (email/SMS/WhatsApp)
        case candidate.preferred_contact_method
        when 'email'
            ReminderMailer.with(candidate: candidate, interview: interview).reminder_email.deliver_now
        when 'sms'
            SmsService.send_reminder(candidate.phone_number, interview)
        when 'whatsapp'
            WhatsappService.send_reminder(candidate.whatsapp_number, interview)
        else
            raise "Unknown contact method: #{candidate.preferred_contact_method}"
        end
    end

    def track_reminder_status(candidate, interview, status)
        # Track the status of the reminder
        interview.update(reminder_status: status)
    end

    def handle_error(candidate, interview, error)
        # Handle errors gracefully
        Rails.logger.error("Failed to send reminder to #{candidate.id} for interview #{interview.id}: #{error.message}")
    end

    def log_statistics
        # Log statistics about reminders
        Rails.logger.info("Reminders sent: #{Interview.where(reminder_status: 'success').count}")
        Rails.logger.info("Reminders failed: #{Interview.where(reminder_status: 'failure').count}")
    end

    def reminder_threshold
        # Configurable timing threshold for reminders
        1.hour
    end
end