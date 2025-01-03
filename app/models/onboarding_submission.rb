class OnboardingSubmission < ApplicationRecord
    # Encryption support
    encrypts :document_number
    encrypts :first_name
    encrypts :last_name
    encrypts :date_of_birth
    encrypts :address
    
    # Validations
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :date_of_birth, presence: true
    validates :document_number, presence: true
    validates :address, presence: true
    validates :status, presence: true
    
    # Status enum
    enum status: {
        pending: 'pending',
        approved: 'approved',
        rejected: 'rejected'
    }
    
    # Associations (assuming you might need these)
    belongs_to :user, optional: true
    
    # Callbacks
    before_validation :set_default_status, on: :create
    
    private
    
    def set_default_status
        self.status ||= :pending
    end
end