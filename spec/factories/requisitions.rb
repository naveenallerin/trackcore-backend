FactoryBot.define do
  factory :requisition do
    sequence(:title) { |n| "Software Engineer Position #{n}" }
    description { "We are looking for a talented software engineer to join our team." }
    location { "Remote" }

    status { :draft }

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

    trait :open do
      status { :open }
    end

    trait :closed do
      status { :closed }
    end
  end
end