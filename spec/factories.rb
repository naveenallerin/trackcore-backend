
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    # Add other necessary attributes
  end
end