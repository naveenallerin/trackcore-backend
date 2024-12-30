class AiDrivenLearningService
  def initialize(user)
    @user = user
    @client = OpenAI::Client.new
  end

  def generate_suggestions
    user_context = build_user_context
    response = query_ai_model(user_context)
    
    parse_and_store_suggestions(response)
  rescue StandardError => e
    Rails.logger.error("AI suggestion error: #{e.message}")
    []
  end

  private

  def build_user_context
    {
      role: @user.role,
      department: @user.department,
      skills: @user.skills,
      experience_level: @user.experience_level
    }
  end

  def query_ai_model(context)
    @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [{
          role: "system",
          content: "Generate learning suggestions based on user context"
        }, {
          role: "user",
          content: context.to_json
        }],
        temperature: 0.7
      }
    )
  end

  def parse_and_store_suggestions(response)
    suggestions = JSON.parse(response.dig("choices", 0, "message", "content"))
    suggestions.map do |suggestion|
      LearningSuggestion.create!(
        user: @user,
        title: suggestion["title"],
        description: suggestion["description"],
        skill_category: suggestion["category"]
      )
    end
  end
end
