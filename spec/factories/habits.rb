FactoryBot.define do
  factory :habit do
    user { nil }
    name { "MyString" }
    description { "MyText" }
    frequency_type { "MyString" }
    recurrence_days { 1 }
    target_value { "9.99" }
    unit { "MyString" }
    category { "MyString" }
    color_hue { 1 }
    position { 1 }
    scheduled_at_minute { 1 }
    duration_minutes { 1 }
    discarded_at { "2026-06-02 09:59:40" }
  end
end
