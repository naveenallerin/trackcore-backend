module ErrorHandling
  extend ActiveSupport::Concern

  included do
    # Add error handling methods
    def handle_error(error)
      case error
      when ActiveRecord::RecordInvalid
        errors.add(:base, error.message)
      when ActiveRecord::RecordNotFound
        errors.add(:base, "Record not found")
      else
        errors.add(:base, "An unexpected error occurred")
      end
      false
    end
  end
end
