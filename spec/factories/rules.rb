FactoryBot.define do
  factory :rule do
    condition_expression { "MyString" }
    action { "MyString" }
    priority { 1 }
    active { false }
  end
end
