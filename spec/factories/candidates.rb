# spec/factories/candidates.rb

FactoryBot.define do
  factory :candidate do
    first_name { 'FactoryFirst' }
    last_name  { 'FactoryLast' }
    sequence(:email) { |n| "candidate#{n}@example.com" }
  end
end
