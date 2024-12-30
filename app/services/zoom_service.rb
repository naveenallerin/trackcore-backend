class ZoomService
  def initialize
    @client = ZoomClient.new(
      client_id: Rails.application.credentials.zoom[:client_id],
      client_secret: Rails.application.credentials.zoom[:client_secret]
    )
  end

  def create_meeting(interview)
    response = @client.meeting_create(
      topic: "Interview with #{interview.candidate.name}",
      start_time: interview.start_time.iso8601,
      duration: ((interview.end_time - interview.start_time) / 60).to_i,
      settings: {
        auto_recording: interview.candidate_consent ? 'cloud' : 'none'
      }
    )
    
    response
  end

  def fetch_recording(meeting_id)
    @client.meeting_recordings(meeting_id)
  end
end
