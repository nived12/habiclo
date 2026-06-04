FactoryBot.define do
  factory :lab_panel do
    user { nil }
    name { "MyString" }
    due_on { "2026-06-02" }
    completed_on { "2026-06-02" }
    result_summary { "MyText" }
  end
end
