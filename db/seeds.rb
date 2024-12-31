# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
puts "Cleaning database..."
Application.destroy_all
Candidate.destroy_all
Requisition.destroy_all

puts "Creating sample data..."

# Create candidates
candidates = 5.times.map do |i|
  Candidate.create!(
    first_name: "Sample#{i}",
    last_name: "Candidate#{i}",
    email: "sample#{i}@example.com"
  )
end

# Create requisitions
requisitions = 3.times.map do |i|
  Requisition.create!(
    title: "Sample Position #{i}",
    description: "This is a sample job description for position #{i}",
    status: [:draft, :open, :closed][i % 3]
  )
end

# Create applications
candidates.each do |candidate|
  requisitions.sample(2).each do |requisition|
    Application.create!(
      candidate: candidate,
      requisition: requisition,
      application_status: [:applied, :screened].sample,
      notes: "Sample application notes for #{candidate.first_name}"
    )
  end
end

puts "Created #{Candidate.count} candidates"
puts "Created #{Requisition.count} requisitions"
puts "Created #{Application.count} applications"
