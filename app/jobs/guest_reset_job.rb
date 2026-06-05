class GuestResetJob < ApplicationJob
  queue_as :default

  def perform
    User.where(guest: true)
        .where.not(data_resets_at: nil)
        .where("data_resets_at < ?", Time.current)
        .find_each do |guest|
      Users::GuestResetter.call(guest)
    rescue StandardError => e
      Rails.logger.error("GuestResetJob failed for user #{guest.id}: #{e.message}")
    end
  end
end
