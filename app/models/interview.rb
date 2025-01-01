class Interview < ApplicationRecord
  belongs_to :requisition
  belongs_to :candidate
  belongs_to :interviewer, class_name: 'User', optional: true

  validates :scheduled_at, presence: true
  validates :interview_type, presence: true
  validates :duration_minutes, presence: true, 
    numericality: { only_integer: true, greater_than: 0 }
  validates :rating, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 1, 
    less_than_or_equal_to: 5,
    allow_nil: true 
  }
  validates :candidate_id, presence: true

  enum status: {
    scheduled: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3,
    no_show: 4
  }

  enum interview_type: {
    phone_screen: 0,
    technical: 1,
    behavioral: 2,
    culture_fit: 3,
    final: 4
  }

  VALID_VIDEO_PROVIDERS = %w[zoom teams].freeze
  
  validates :video_provider, inclusion: { in: VALID_VIDEO_PROVIDERS }, allow_nil: true
  validates :video_link, presence: true, if: :video_provider?
  
  scope :with_recording, -> { where.not(recording_url: nil) }
  scope :active, -> { where(deleted_at: nil) }
  scope :upcoming, -> { where('scheduled_at > ?', Time.current).order(scheduled_at: :asc) }
  scope :past, -> { where('scheduled_at < ?', Time.current).order(scheduled_at: :desc) }
  scope :for_interviewer, ->(user_id) { where(interviewer_id: user_id) }
  scope :needs_feedback, -> { completed.where(feedback: nil) }

  after_create :schedule_calendar_sync

  def generate_video_link
    return unless video_provider && candidate_consent
    
    service = case video_provider
              when 'zoom' then ZoomService.new
              when 'teams' then TeamsService.new
              end
              
    meeting = service.create_meeting(self)
    update(video_link: meeting.join_url)
  end

  def process_recording
    return unless recording_url && candidate_consent
    ProcessRecordingJob.perform_later(id)
  end

  def duration_in_hours
    (duration_minutes.to_f / 60).round(2)
  end

  def send_calendar_invite
    InterviewCalendarJob.perform_async(id)
  end

  private

  def schedule_calendar_sync
    CalendarSyncJob.perform_later(self)
  end
end
