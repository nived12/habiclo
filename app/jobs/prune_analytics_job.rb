class PruneAnalyticsJob < ApplicationJob
  queue_as :background

  RETAIN_MONTHS = 6

  def perform
    cutoff = RETAIN_MONTHS.months.ago
    Ahoy::Event.where("time < ?", cutoff).delete_all
    Ahoy::Visit.where("started_at < ?", cutoff).delete_all
  end
end
