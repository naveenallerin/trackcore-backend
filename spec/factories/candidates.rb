FactoryBot.define do
  factory :candidate do
    sequence(:email) { |n| "candidate#{n}@example.com" }
    password { 'password123' }
    first_name { "MyString" }
    last_name { "MyString" }
  end
end
