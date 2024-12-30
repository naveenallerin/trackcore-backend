class ProcessRecordingJob < ApplicationJob
  queue_as :default

  def perform(interview_id)
    interview = Interview.find(interview_id)
    return unless interview.recording_url && interview.candidate_consent

    transcript = TranscriptionService.new.transcribe(interview.recording_url)
    sentiment = SentimentService.new.analyze(transcript)
    
    interview.update(
      transcript: transcript,
      sentiment_score: sentiment,
      recording_status: 'processed'
    )
  end
end
