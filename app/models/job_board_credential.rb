class JobBoardCredential < ApplicationRecord
  belongs_to :organization
  
  validates :provider, presence: true
  validates :api_key, presence: true
  validates :provider, uniqueness: { scope: :organization_id }
  
  encrypts :api_key, :api_secret
  
  enum provider: {
    indeed: 'indeed',
    linkedin: 'linkedin',
    ziprecruiter: 'ziprecruiter'
  }
end
