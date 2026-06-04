FactoryBot.define do
  factory :biometric_entry do
    user { nil }
    recorded_on { "2026-06-02" }
    recorded_at_minute { 1 }
    metric { "MyString" }
    value { "9.99" }
    source { "MyString" }
  end
end
