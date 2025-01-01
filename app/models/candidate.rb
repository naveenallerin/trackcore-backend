class Candidate < ApplicationRecord
  belongs_to :requisition, optional: true
  has_many :notes
  has_many :interviews
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true, length: { minimum: 2 }
  validates :primary_skill, presence: true, unless: :draft?
  validates :location, presence: true, unless: :draft?
  validates :status, presence: true, inclusion: { in: %w[active inactive withdrawn hired] }
  
  def full_name
    "#{first_name} #{last_name}".strip
  end

  scope :active, -> { where(status: 'active') }

  # Search scopes
  scope :filter_by_keyword, ->(keyword) {
    return all if keyword.blank?
    where("resume_text ILIKE :term OR 
           first_name ILIKE :term OR 
           last_name ILIKE :term OR 
           primary_skill ILIKE :term",
           term: "%#{sanitize_sql_like(keyword)}%")
  }

  scope :by_location, ->(location) {
    return all if location.blank?
    where("location ILIKE ?", "%#{sanitize_sql_like(location)}%")
  }

  scope :by_skill, ->(skill) {
    return all if skill.blank?
    where("primary_skill ILIKE ?", "%#{sanitize_sql_like(skill)}%")
  }

  scope :search_full_text, ->(query) {
    return all if query.blank?
    
    where("to_tsvector('english', resume_text || ' ' || 
           first_name || ' ' || 
           last_name || ' ' || 
           COALESCE(primary_skill, '') || ' ' || 
           COALESCE(location, '')) @@ plainto_tsquery('english', ?)", 
           query)
  }

  include PgSearch::Model
  
  pg_search_scope :search_by_all_fields,
    against: {
      first_name: 'A',
      last_name: 'A',
      email: 'B',
      primary_skill: 'B',
      location: 'C',
      resume_text: 'D'
    },
    using: {
      tsearch: { 
        prefix: true,
        dictionary: 'english',
        tsvector_column: 'searchable_content'
      }
    }

  # Enhanced scopes
  scope :with_skills, ->(skills) {
    return all if skills.blank?
    where("primary_skill && ARRAY[?]::varchar[]", Array(skills))
  }

  scope :by_experience_range, ->(min, max) {
    return all if min.blank? && max.blank?
    where("years_of_experience BETWEEN ? AND ?", min || 0, max || Float::INFINITY)
  }

  scope :by_salary_range, ->(min, max) {
    return all if min.blank? && max.blank?
    where("expected_salary BETWEEN ? AND ?", min || 0, max || Float::INFINITY)
  }

  scope :available_for_interview, -> {
    active.where.not(id: Interview.scheduled.select(:candidate_id))
  }

  scope :recently_active, -> {
    where('last_activity_at > ?', 30.days.ago)
  }

  scope :potential_matches, ->(requisition) {
    where("primary_skill && ARRAY[?]::varchar[]", requisition.required_skills)
      .where("years_of_experience >= ?", requisition.minimum_experience)
      .where("expected_salary <= ?", requisition.maximum_salary)
  }

  # Combined search method
  def self.advanced_search(params)
    candidates = all

    candidates = candidates.search_by_all_fields(params[:query]) if params[:query].present?
    candidates = candidates.with_skills(params[:skills]) if params[:skills].present?
    candidates = candidates.by_location(params[:location]) if params[:location].present?
    candidates = candidates.by_experience_range(params[:min_experience], params[:max_experience])
    candidates = candidates.by_salary_range(params[:min_salary], params[:max_salary])
    
    candidates = candidates.order(sort_order(params[:sort_by], params[:sort_direction]))
    
    candidates
  end

  def update_resume_text(text)
    update(resume_text: text)
    ResumeParsingJob.perform_async(id) if text_changed?
  end

  private

  def draft?
    status == 'draft'
  end

  def self.sort_order(sort_by, direction)
    direction = %w[asc desc].include?(direction) ? direction : 'desc'
    
    case sort_by
    when 'experience'
      { years_of_experience: direction }
    when 'salary'
      { expected_salary: direction }
    when 'last_active'
      { last_activity_at: direction }
    else
      { created_at: direction }
    end
  end

  # Add geocoding
  geocoded_by :location
  after_validation :geocode, if: ->(obj) { obj.location_changed? }

  # Enhanced search scopes
  scope :fuzzy_name_match, ->(name) {
    return all if name.blank?
    where("similarity(first_name || ' ' || last_name, ?) > 0.3", name)
      .order(Arel.sql("similarity(first_name || ' ' || last_name, #{connection.quote(name)}) DESC"))
  }

  scope :near_location, ->(location, radius_km = 50) {
    return all if location.blank?
    
    coordinates = Geocoder.coordinates(location)
    return none if coordinates.nil?
    
    where("ST_DistanceSphere(coordinates, ST_MakePoint(?, ?)) <= ?",
          coordinates[1], coordinates[0], radius_km * 1000)
      .order(Arel.sql("ST_DistanceSphere(coordinates, ST_MakePoint(#{coordinates[1]}, #{coordinates[0]}))"))
  }

  scope :with_similar_skills, ->(skills, threshold = 0.6) {
    return all if skills.blank?
    
    skill_array = Array(skills)
    where("skills && ARRAY[?]::varchar[]", skill_array)
      .or(where("EXISTS (
        SELECT 1 FROM unnest(skills) skill
        WHERE EXISTS (
          SELECT 1 FROM unnest(ARRAY[?]::varchar[]) search_skill
          WHERE similarity(skill, search_skill) > ?
        )
      )", skill_array, threshold))
  }

  include CandidateScoring
  include SkillMatching

  def self.advanced_search(params)
    SearchCache.cached_search(params) do
      results = search_scope(params)
      results = apply_filters(results, params)
      results = apply_scoring(results, params)
      results = apply_pagination(results, params)
      
      {
        results: results,
        total_count: results.total_count,
        facets: generate_facets(results)
      }
    end
  end

  private

  def self.search_scope(params)
    base_scope = all

    if params[:query].present?
      base_scope = base_scope.search_by_all_fields(params[:query])
    end

    if params[:skills].present?
      base_scope = base_scope.find_by_skill_similarity(params[:skills])
    end

    base_scope
  end

  def self.apply_filters(scope, params)
    scope = scope.near_location(params[:location], params[:radius]) if params[:location].present?
    scope = scope.by_experience_range(params[:min_experience], params[:max_experience])
    scope = scope.by_salary_range(params[:min_salary], params[:max_salary])
    scope
  end

  def self.apply_scoring(scope, params)
    scope.select("candidates.*, 
      ts_rank_cd(searchable_content, plainto_tsquery('english', :query)) * 0.3 +
      skill_similarity(skills, ARRAY[:skills]::varchar[]) * 0.4 +
      search_score * 0.3 as match_score", 
      query: params[:query],
      skills: Array(params[:skills])
    ).order('match_score DESC')
  end

  def self.generate_facets(results)
    {
      skills: results.pluck(:skills).flatten.tally,
      locations: results.group(:location).count,
      experience_levels: results.group(:years_of_experience).count
    }
  end

  def update_search_score
    score = calculate_profile_completeness +
            calculate_skill_relevance +
            calculate_experience_value +
            calculate_engagement_score

    update_column(:search_score, score)
  end

  private

  def calculate_profile_completeness
    fields = [first_name, last_name, email, location, primary_skill, resume_text]
    (fields.count(&:present?).to_f / fields.size) * 0.25
  end

  def calculate_skill_relevance
    return 0 unless skills.present?
    
    in_demand_skills = Rails.cache.fetch('in_demand_skills', expires_in: 1.day) do
      Requisition.open
                .pluck(:required_skills)
                .flatten
                .tally
                .sort_by { |_, count| -count }
                .first(10)
                .map(&:first)
    end

    matching_skills = (skills & in_demand_skills).size
    (matching_skills.to_f / in_demand_skills.size) * 0.25
  end

  def calculate_experience_value
    return 0 unless years_of_experience
    [years_of_experience.to_f / 10, 0.25].min
  end

  def calculate_engagement_score
    return 0 unless last_activity_at
    
    days_since_activity = (Time.current - last_activity_at).to_f / 1.day
    engagement_score = 1 - [days_since_activity / 30, 1].min
    engagement_score * 0.25
  end

  # Resume parsing optimization
  def parse_resume
    return unless resume_text_changed?

    parsed_data = ResumeParser.parse(resume_text)
    
    self.parsed_resume_data = {
      education: parsed_data.education,
      experience: parsed_data.experience,
      skills: parsed_data.skills,
      certifications: parsed_data.certifications
    }

    self.skills = parsed_data.skills
    self.years_of_experience = parsed_data.total_experience
    
    update_search_score
  end

  include CacheableQuery

  cached_query :top_candidates_for_skills, expires_in: 1.hour do |skills|
    with_similar_skills(skills)
      .where(status: 'active')
      .order(search_score: :desc)
      .limit(10)
  end

  cached_query :market_demand_report, expires_in: 12.hours do
    MarketDemandAnalyzerService.new.analyze_demand
  end

  before_save :normalize_skills
  after_commit :update_market_demand_cache, if: :skills_changed?

  private

  def normalize_skills
    return unless skills_changed?
    
    self.skills = skills.map do |skill|
      SkillNormalizerService.instance.normalize(skill)
    end.compact.uniq
  end

  def update_market_demand_cache
    Rails.cache.delete_matched("market_demand*")
  end
end
