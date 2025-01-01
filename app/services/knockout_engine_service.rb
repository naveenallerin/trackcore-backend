class KnockoutEngineService
  Result = Struct.new(:passed, :failed_rules, :errors, keyword_init: true) do
    def passed?
      passed && errors.empty?
    end
  end

  def initialize(rules = nil)
    @rules = rules || KnockoutRule.active.by_priority
  end

  def evaluate_candidate(candidate)
    failed_rules = []
    errors = []

    @rules.each do |rule|
      begin
        next if rule.rule_expression.blank?
        
        unless meets_rule?(candidate, rule)
          failed_rules << {
            rule_id: rule.id,
            name: rule.name,
            reason: generate_failure_reason(rule)
          }
        end
      rescue StandardError => e
        errors << "Error evaluating rule #{rule.name}: #{e.message}"
      end
    end

    Result.new(
      passed: failed_rules.empty?,
      failed_rules: failed_rules,
      errors: errors
    )
  end

  def evaluate_multiple(candidates)
    candidates.map { |candidate| [candidate.id, evaluate_candidate(candidate)] }.to_h
  end

  private

  def meets_rule?(candidate, rule)
    case rule.rule_expression['type']
    when KnockoutRule::RULE_TYPES[:experience]
      evaluate_experience_rule(candidate, rule.rule_expression['condition'])
    when KnockoutRule::RULE_TYPES[:skills]
      evaluate_skills_rule(candidate, rule.rule_expression['condition'])
    when KnockoutRule::RULE_TYPES[:education]
      evaluate_education_rule(candidate, rule.rule_expression['condition'])
    when KnockoutRule::RULE_TYPES[:location]
      evaluate_location_rule(candidate, rule.rule_expression['condition'])
    else
      raise ArgumentError, "Unsupported rule type: #{rule.rule_expression['type']}"
    end
  end

  def evaluate_experience_rule(candidate, condition)
    years = calculate_total_experience(candidate)
    compare_numeric(years, condition['operator'], condition['value'])
  end

  def evaluate_skills_rule(candidate, condition)
    candidate_skills = candidate.skills.pluck(:name) + (candidate.inferred_skills || [])
    required_skills = condition['value']

    case condition['operator']
    when 'includes_all'
      (required_skills - candidate_skills).empty?
    when 'includes_any'
      (required_skills & candidate_skills).any?
    when 'excludes'
      (required_skills & candidate_skills).empty?
    else
      raise ArgumentError, "Invalid skills operator: #{condition['operator']}"
    end
  end

  def evaluate_education_rule(candidate, condition)
    education_level = get_highest_education_level(candidate)
    required_level = condition['value']

    case condition['operator']
    when 'minimum_degree'
      EDUCATION_LEVELS.index(education_level).to_i >= 
      EDUCATION_LEVELS.index(required_level).to_i
    when 'exact_degree'
      education_level == required_level
    else
      raise ArgumentError, "Invalid education operator: #{condition['operator']}"
    end
  end

  def evaluate_location_rule(candidate, condition)
    case condition['operator']
    when 'in_country'
      candidate.location&.country == condition['value']
    when 'in_region'
      candidate.location&.region == condition['value']
    when 'remote_allowed'
      candidate.remote_work_possible == condition['value']
    else
      raise ArgumentError, "Invalid location operator: #{condition['operator']}"
    end
  end

  def compare_numeric(value, operator, threshold)
    case operator
    when '>' then value > threshold
    when '>=' then value >= threshold
    when '<' then value < threshold
    when '<=' then value <= threshold
    when '=' then value == threshold
    else
      raise ArgumentError, "Invalid numeric operator: #{operator}"
    end
  end

  def calculate_total_experience(candidate)
    candidate.work_experiences
            .sum { |exp| calculate_duration_in_years(exp.start_date, exp.end_date) }
  end

  def calculate_duration_in_years(start_date, end_date)
    return 0 unless start_date

    end_date = Date.current if end_date.nil?
    ((end_date - start_date).to_f / 365).round(1)
  end

  def get_highest_education_level(candidate)
    candidate.educations
            .map(&:degree_level)
            .max_by { |degree| EDUCATION_LEVELS.index(degree) || -1 }
  end

  def generate_failure_reason(rule)
    "Failed #{rule.name}: #{rule.description}"
  end

  EDUCATION_LEVELS = [
    'high_school',
    'associates',
    'bachelors',
    'masters',
    'doctorate',
    'post_doctorate'
  ].freeze
end
