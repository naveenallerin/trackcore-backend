class LicenseMailer < ApplicationMailer
  def expiration_reminder(candidate_license)
    @candidate = candidate_license.candidate
    @license = candidate_license
    @days_until_expiry = (@license.expiration_date - Date.current).to_i

    mail(
      to: @candidate.email,
      subject: "License Expiration Reminder - #{@license.license_type.name}"
    )
  end
end
