# spec/factories/candidates.rb
factory :candidate do
  sequence(:email) { |n| "candidate#{n}@example.com" }
  password { 'password123' }
end

# spec/factories/candidate_documents.rb
factory :candidate_document do
  candidate
  title { 'Test Document' }
  file { Rack::Test::UploadedFile.new('spec/fixtures/test.pdf') }
end