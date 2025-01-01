class CandidateLicenseSerializer < ActiveModel::Serializer
  attributes :id,
             :license_number,
             :status,
             :issuing_authority,
             :issued_date,
             :expiration_date,
             :notes,
             :created_at,
             :updated_at

  belongs_to :candidate
  belongs_to :license_type
end
