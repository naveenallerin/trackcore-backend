module Searchable
  extend ActiveSupport::Concern

  included do
    # Add common search functionality here
    scope :search, ->(query) do
      where("LOWER(name) LIKE ?", "%#{query.downcase}%") if query.present?
    end
  end
end
