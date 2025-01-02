class EmailTemplateRenderer
  class MissingVariableError < StandardError
    attr_reader :missing_variables
    
    def initialize(missing)
      @missing_variables = missing
      super("Missing required variables: #{missing.join(', ')}")
    end
  end

  class RenderResult
    attr_reader :subject, :body, :warnings

    def initialize(subject:, body:, warnings: [])
      @subject = subject
      @body = body
      @warnings = warnings
    end
  end

  def self.render(template, variables = {})
    new(template, variables).render
  end

  def initialize(template, variables = {})
    @template = template
    @variables = variables.transform_keys(&:to_s)
    @warnings = []
  end

  def render
    validate_required_variables!
    
    rendered_subject = render_text(@template.subject)
    rendered_body = render_text(@template.body)
    rendered_footer = @template.footer.present? ? "\n\n#{render_text(@template.footer)}" : ""

    RenderResult.new(
      subject: rendered_subject,
      body: rendered_body + rendered_footer,
      warnings: @warnings
    )
  end

  private

  def render_text(text)
    text.gsub(/\{\{([^}]+)\}\}/) do |match|
      variable_name = $1.strip
      if @variables.key?(variable_name)
        @variables[variable_name].to_s
      else
        @warnings << "Undefined variable: #{variable_name}"
        match # Keep original placeholder if variable is not provided
      end
    end
  end

  def validate_required_variables!
    return unless @template.required_placeholders.any?

    missing = @template.required_placeholders - @variables.keys
    raise MissingVariableError.new(missing) if missing.any?
  end
end
