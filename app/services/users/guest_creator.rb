module Users
  class GuestCreator < ApplicationService
    def initialize(time_zone: "America/Mexico_City", locale: "es")
      @time_zone = time_zone
      @locale = locale
    end

    def call
      token = SecureRandom.hex(8)
      password = SecureRandom.hex(16)
      user = User.create!(
        email: "guest_#{token}@habiclo.local",
        password: password,
        password_confirmation: password,
        guest: true,
        time_zone: @time_zone,
        locale: @locale,
        data_resets_at: Users::GuestResetter::TTL.from_now
      )
      Templates::Applier.new(user, "welcome").call
      user
    end
  end
end
