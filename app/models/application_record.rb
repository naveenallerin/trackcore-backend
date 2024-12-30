class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Load concerns in specific order
  include CacheableAssociations
  include Auditable
  include Searchable
  include ErrorHandling
  
  # Add default ordering by created_at
  default_scope { order(created_at: :desc) }

  
  # Common timestamp helpers
  def created_ago
    time_ago_in_words(created_at)
  end

  def updated_ago
    time_ago_in_words(updated_at)
  end

  # Add performance monitoring
  after_initialize :log_initialization, if: -> { Rails.env.development? }
  
  class << self
    def safe_find(id)
      find_by(id: id)
    end

    def find_or_error(id)
      find_by(id: id) || raise(ActiveRecord::RecordNotFound)
    end
  end

  protected
  
  private

  def log_initialization
    Rails.logger.debug "Initialized #{self.class.name} ##{id}"
  end
  
  def time_ago_in_words(time)
    return 'never' if time.nil?
    super(time)
  rescue
    'unknown'
  end

  def log_error(message, error)
    Rails.logger.error("#{self.class.name} Error: #{message} - #{error.message}")
    Rails.logger.debug(error.backtrace.join("\n")) if Rails.env.development?
  end
end
