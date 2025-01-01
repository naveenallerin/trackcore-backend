class LicenseExpirationReminderJob
  include Sidekiq::Job

  sidekiq_options queue: :default, retry: 3

  def perform
    process_expiring_licenses
    update_expired_licenses
  end

  private

  def process_expiring_licenses
    CandidateLicense.expiring_soon.find_each do |license|
      send_reminder(license)
      log_reminder(license)
    rescue StandardError => e
      Rails.logger.error "Failed to process reminder for license #{license.id}: #{e.message}"
      Sentry.capture_exception(e) if defined?(Sentry)
    end
  end

  def update_expired_licenses
    CandidateLicense.expired_not_updated.find_each do |license|
      license.update!(status: 'expired')
    rescue StandardError => e
      Rails.logger.error "Failed to update expired license #{license.id}: #{e.message}"
      Sentry.capture_exception(e) if defined?(Sentry)
    end
  end

  def send_reminder(license)
    LicenseMailer.expiration_reminder(license).deliver_later
  end

  def log_reminder(license)
    Rails.logger.info(
      "License expiration reminder sent: " \
      "Candidate: #{license.candidate_id}, " \
      "License: #{license.license_type.name}, " \
      "Expires: #{license.expiration_date}"
    )
  end
end
