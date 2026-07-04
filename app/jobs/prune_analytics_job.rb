class PruneAnalyticsJob < ApplicationJob
  queue_as :background

  RETAIN_DAYS = 90

  def perform
    cutoff = RETAIN_DAYS.days.ago
    # Batched so a large backlog can't build one oversized delete (and its WAL spike).
    Ahoy::Event.where("time < ?", cutoff).in_batches.delete_all
    Ahoy::Visit.where("started_at < ?", cutoff).in_batches.delete_all
  end
end
