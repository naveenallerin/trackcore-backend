class JobPostingAttempt < ApplicationRecord
  belongs_to :job
  belongs_to :job_board_credential

  validates :status, presence: true
  validates :attempt_number, presence: true

  enum status: {
    pending: 'pending',
    success: 'success',
    failed: 'failed',
    rate_limited: 'rate_limited'
  }

  def self.track_attempt(job, credential)
    attempt = create!(
      job: job,
      job_board_credential: credential,
      attempt_number: next_attempt_number(job, credential),
      status: :pending
    )

    yield(attempt)
  rescue JobBoard::RateLimitError => e
    attempt.update!(status: :rate_limited, error_message: e.message)
    raise
  rescue => e
    attempt.update!(status: :failed, error_message: e.message)
    raise
  end

  private

  def self.next_attempt_number(job, credential)
    where(job: job, job_board_credential: credential).count + 1
  end
end
