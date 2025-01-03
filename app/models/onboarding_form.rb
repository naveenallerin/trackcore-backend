class OnboardingForm < ApplicationRecord
    # Validations
    validates :status, presence: true

    # Possible statuses for the onboarding form
    enum status: {
        draft: 0,
        submitted: 1,
        approved: 2,
        rejected: 3
    }
end