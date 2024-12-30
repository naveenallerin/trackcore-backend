class TemplateRendererService
  def self.render_content(body, placeholders = {})
    result = body.dup
    
    placeholders.each do |key, value|
      result.gsub!(/\{\{#{key}\}\}/, value.to_s)
    end
    
    result
  end
end
