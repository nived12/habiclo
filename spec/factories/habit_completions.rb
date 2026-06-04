FactoryBot.define do
  factory :habit_completion do
    habit { nil }
    completed_on { "2026-06-02" }
    completed_at_minute { 1 }
    value { "9.99" }
    notes { "MyText" }
  end
end
