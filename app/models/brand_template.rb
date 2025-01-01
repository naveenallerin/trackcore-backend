class BrandTemplate < ApplicationRecord
  belongs_to :company
  has_many :requisitions

  validates :brand_name, presence: true, uniqueness: { scope: :company_id }
  validates :template_html, presence: true
  validates :brand_color, format: { with: /\A#?(?:[A-F0-9]{3}){1,2}\z/i, allow_blank: true }
  validates :brand_logo_url, url: true, allow_blank: true

  before_save :ensure_template_variables

  def render_template(context = {})
    template = template_html.dup
    merged_context = template_variables.merge(context.stringify_keys)
    
    merged_context.each do |key, value|
      template.gsub!(/\{\{\s*#{key}\s*\}\}/, value.to_s)
    end
    
    template
  end

  private

  def ensure_template_variables
    self.template_variables = template_variables.stringify_keys
  end
end
