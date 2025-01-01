class LicenseType < ApplicationRecord
  has_many :candidate_licenses
  has_many :candidates, through: :candidate_licenses

  validates :name, presence: true, uniqueness: true

  scope :find_by_name, ->(name) { where('name ILIKE ?', "%#{name}%") }
end
