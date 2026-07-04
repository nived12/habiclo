require 'rails_helper'

RSpec.describe PruneAnalyticsJob, type: :job do
  # Regression guard: the prune window silently retained 6 months and never fired
  # on a young project, letting ahoy_* fill the Postgres volume (July 2026).
  def visit_at(time)
    Ahoy::Visit.create!(visit_token: SecureRandom.uuid, visitor_token: SecureRandom.uuid, started_at: time)
  end

  it "deletes visits and events older than the retention window" do
    old_visit = visit_at(PruneAnalyticsJob::RETAIN_DAYS.days.ago - 1.day)
    old_event = Ahoy::Event.create!(
      visit: old_visit, name: "$view",
      time: PruneAnalyticsJob::RETAIN_DAYS.days.ago - 1.day
    )

    described_class.perform_now

    expect(Ahoy::Visit.exists?(old_visit.id)).to be(false)
    expect(Ahoy::Event.exists?(old_event.id)).to be(false)
  end

  it "keeps visits and events within the retention window" do
    fresh_visit = visit_at(1.day.ago)
    fresh_event = Ahoy::Event.create!(visit: fresh_visit, name: "$view", time: 1.day.ago)

    described_class.perform_now

    expect(Ahoy::Visit.exists?(fresh_visit.id)).to be(true)
    expect(Ahoy::Event.exists?(fresh_event.id)).to be(true)
  end
end
