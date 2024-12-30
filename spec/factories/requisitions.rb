FactoryBot.define do
  factory :requisition do
    sequence(:title) { |n| "Software Engineer #{n}" }
    description { "Great opportunity" }
    location { "Remote" }
    status { "open" }

    trait :with_approvals do
      after(:create) do |requisition|
        create(:approval_request, requisition: requisition)
      end
    end

    trait :with_job_posting do
      after(:create) do |requisition|
        create(:job_posting, requisition: requisition)
      end
    end
  end
end
