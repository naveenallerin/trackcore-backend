FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    role { 'manager' }
    
    trait :admin do
      role { 'admin' }
    end
    
    trait :basic do
      role { 'basic' }
    end
  end
end
