FactoryBot.define do
    factory :application do
      association :candidate
      association :requisition
      application_status { :applied }
      notes { "Initial application notes" }
  
      trait :screened do
        application_status { :screened }
      end
  
      trait :with_notes do
        notes { "Detailed notes about the candidate's application" }
      end
    end
  end