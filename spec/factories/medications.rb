FactoryBot.define do
  factory :medication do
    user { nil }
    name { "MyString" }
    dose { "MyString" }
    schedule_minutes { 1 }
    notes { "MyText" }
    discarded_at { "2026-06-02 09:59:48" }
  end
end
