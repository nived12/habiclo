FactoryBot.define do
  factory :agenda_item do
    user { nil }
    title { "MyString" }
    notes { "MyText" }
    occurs_on { "2026-06-02" }
    scheduled_at_minute { 1 }
    duration_minutes { 1 }
    kind { "MyString" }
    linked_type { "MyString" }
    linked_id { "" }
    discarded_at { "2026-06-02 09:59:44" }
  end
end
