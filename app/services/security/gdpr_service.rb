class IntegrationConfig < ApplicationRecord
  encrypts :api_key, :api_secret
  
  validates :provider_name, presence: true, uniqueness: true
  validates :api_key, presence: true
  
  scope :active, -> { where(active: true) }
  
  def sync_due?
    last_sync_at.nil? || last_sync_at < 1.hour.ago
  end
end