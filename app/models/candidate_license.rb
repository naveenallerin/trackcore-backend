class CandidateLicense < ApplicationRecord
  belongs_to :candidate
  belongs_to :license_type

  validates :candidate_id, presence: true
  validates :license_type_id, presence: true
  validates :license_number, presence: true
  validates :issue_date, presence: true
  validates :status, inclusion: { in: %w[active expired revoked] }

  def expired?
    return false if expiration_date.nil?
    expiration_date < Date.current
  end

  def active?
    status == 'active' && !expired?
  end

  before_save :update_status_on_expiration

  private

  def update_status_on_expiration
    self.status = 'expired' if expired?
  end
end
