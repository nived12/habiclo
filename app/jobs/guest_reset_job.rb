class GuestResetJob < ApplicationJob
  queue_as :default

  def perform
    deleted = 0
    User.where(guest: true)
        .where.not(data_resets_at: nil)
        .where("data_resets_at < ?", Time.current)
        .find_each do |guest|
      guest.destroy
      deleted += 1
    rescue StandardError => e
      Rails.logger.error("GuestResetJob failed for user #{guest.id}: #{e.message}")
    end
    Rails.logger.info("GuestResetJob swept #{deleted} expired guests")
  end
end
