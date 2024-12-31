class CandidateSerializer < ActiveModel::Serializer
  # ...existing code...
  
  attribute :resume_url do
    if object.resume.attached?
      Rails.application.routes.url_helpers.rails_blob_url(object.resume, only_path: true)
    end
  end
  
  # ...existing code...
end
