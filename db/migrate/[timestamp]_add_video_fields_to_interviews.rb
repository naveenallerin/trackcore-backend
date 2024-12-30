class AddVideoFieldsToInterviews < ActiveRecord::Migration[7.0]
  def change
    add_column :interviews, :video_provider, :string
    add_column :interviews, :video_link, :string
    add_column :interviews, :recording_url, :string
    add_column :interviews, :transcript, :text
    add_column :interviews, :sentiment_score, :float
    add_column :interviews, :candidate_consent, :boolean, default: false
    add_column :interviews, :recording_status, :string, default: 'pending'
    add_column :interviews, :deleted_at, :datetime
    
    add_index :interviews, :video_provider
    add_index :interviews, :recording_status
    add_index :interviews, :deleted_at
  end
end
