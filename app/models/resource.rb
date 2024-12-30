class Resource < ApplicationRecord
  has_many :resource_feedbacks, dependent: :destroy
  has_many :users, through: :resource_feedbacks

  validates :title, presence: true
  validates :category, presence: true
  validates :status, inclusion: { in: %w[active archived draft] }

  scope :active, -> { where(status: 'active') }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_region, ->(region) { where(region_restriction: [nil, region]) }

  def increment_version!
    self.version_history[version.to_s] = attributes.slice('title', 'body_html', 'file_url')
    self.version += 1
    save!
  end

  def revert_to_version!(target_version)
    return false unless version_history[target_version.to_s]
    
    old_version = version_history[target_version.to_s]
    update!(
      title: old_version['title'],
      body_html: old_version['body_html'],
      file_url: old_version['file_url'],
      version: target_version
    )
  end
end
