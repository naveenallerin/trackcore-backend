class Interview < ApplicationRecord
  # ...existing code...
  
  VALID_VIDEO_PROVIDERS = %w[zoom teams].freeze
  
  validates :video_provider, inclusion: { in: VALID_VIDEO_PROVIDERS }, allow_nil: true
  validates :video_link, presence: true, if: :video_provider?
  
  scope :with_recording, -> { where.not(recording_url: nil) }
  scope :active, -> { where(deleted_at: nil) }
  
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
end
