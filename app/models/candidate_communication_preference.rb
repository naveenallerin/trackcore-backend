class CandidateCommunicationPreference < ApplicationRecord
  belongs_to :candidate

  validates :candidate_id, presence: true
  validates :channel, presence: true, inclusion: { in: %w[sms whatsapp email] }
  validates :opt_in, inclusion: { in: [true, false] }
  validates :phone_number, presence: true, if: :requires_phone_number?
  validates :phone_number, format: { with: /\A\+?[\d\s-]{10,}\z/ }, allow_nil: true
  
  # Prevent duplicate channels for the same candidate
  validates :channel, uniqueness: { scope: :candidate_id }

  private

  def requires_phone_number?
    %w[sms whatsapp].include?(channel)
  end
end
