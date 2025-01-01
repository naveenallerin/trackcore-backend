class CandidateMergeService
  class MergeError < StandardError; end

  def self.call(source_candidate, target_candidate)
    new(source_candidate, target_candidate).merge_candidates
  end

  def initialize(source_candidate, target_candidate)
    @source = source_candidate
    @target = target_candidate
    @errors = []
  end

  def merge_candidates
    return failure("Source and target candidates must be different") if @source.id == @target.id
    return failure("Source candidate not found") unless @source
    return failure("Target candidate not found") unless @target

    ActiveRecord::Base.transaction do
      merge_basic_attributes
      merge_associations
      mark_source_as_merged

      success("Successfully merged candidates")
    rescue ActiveRecord::RecordInvalid => e
      raise MergeError, "Failed to merge: #{e.message}"
    rescue StandardError => e
      raise MergeError, "Unexpected error during merge: #{e.message}"
    end
  rescue MergeError => e
    failure(e.message)
  end

  private

  def merge_basic_attributes
    mergeable_attributes.each do |attr|
      next if @target.send(attr).present?
      next if @source.send(attr).blank?

      @target.update_column(attr, @source.send(attr))
    end

    # Merge arrays and hashes
    merge_array_attributes
    merge_hash_attributes
  end

  def mergeable_attributes
    %w[
      phone
      alternate_email
      linkedin_url
      github_url
      portfolio_url
      current_company
      current_title
      years_of_experience
      education_level
      resume_text
    ]
  end

  def merge_array_attributes
    # Merge skills arrays, removing duplicates
    combined_skills = (@target.skills + @source.skills).uniq
    @target.update_column(:skills, combined_skills)

    # Merge other array fields if they exist
    if @target.respond_to?(:certifications) && @source.respond_to?(:certifications)
      combined_certs = (@target.certifications + @source.certifications).uniq
      @target.update_column(:certifications, combined_certs)
    end
  end

  def merge_hash_attributes
    # Merge parsed resume data, preferring target's data
    if @target.respond_to?(:parsed_resume_data) && @source.respond_to?(:parsed_resume_data)
      merged_resume_data = @target.parsed_resume_data.merge(@source.parsed_resume_data) do |_key, target_val, source_val|
        target_val.present? ? target_val : source_val
      end
      @target.update_column(:parsed_resume_data, merged_resume_data)
    end
  end

  def merge_associations
    move_association(:notes)
    move_association(:interviews)
    move_association(:licenses)
    move_association(:documents)
    move_association(:applications)
    move_association(:candidate_evaluations)
    move_association(:feedback_responses)
    
    # Handle special cases
    merge_timeline_events
    update_related_records
  end

  def move_association(association)
    return unless @source.respond_to?(association)
    
    records = @source.send(association)
    return if records.empty?

    records.update_all(candidate_id: @target.id)
  rescue ActiveRecord::RecordInvalid => e
    raise MergeError, "Failed to merge #{association}: #{e.message}"
  end

  def merge_timeline_events
    return unless defined?(TimelineEvent)

    TimelineEvent.where(
      subject_type: 'Candidate',
      subject_id: @source.id
    ).update_all(subject_id: @target.id)

    TimelineEvent.where(
      associated_type: 'Candidate',
      associated_id: @source.id
    ).update_all(associated_id: @target.id)
  end

  def update_related_records
    # Update any polymorphic relationships
    update_polymorphic_associations

    # Update any direct references in other models
    update_direct_references
  end

  def update_polymorphic_associations
    # List of models with polymorphic associations to Candidate
    polymorphic_models = [
      Activity,
      Attachment,
      Comment,
      Notification
    ].select { |m| defined?(m) }

    polymorphic_models.each do |model|
      model.where(subject_type: 'Candidate', subject_id: @source.id)
           .update_all(subject_id: @target.id)
    end
  end

  def update_direct_references
    # Update any models that directly reference candidates
    if defined?(Message)
      Message.where(sender_id: @source.id, sender_type: 'Candidate')
             .update_all(sender_id: @target.id)
      Message.where(recipient_id: @source.id, recipient_type: 'Candidate')
             .update_all(recipient_id: @target.id)
    end
  end

  def mark_source_as_merged
    @source.update_columns(
      status: 'merged',
      merged_into_id: @target.id,
      merged_at: Time.current,
      email: "#{@source.email}.merged.#{Time.current.to_i}"
    )
  end

  def success(message)
    {
      success: true,
      message: message,
      target_candidate: @target,
      source_candidate: @source
    }
  end

  def failure(message)
    {
      success: false,
      message: message,
      errors: @errors
    }
  end
end
