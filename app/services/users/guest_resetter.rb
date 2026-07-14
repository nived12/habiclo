module Users
  class GuestResetter < ApplicationService
    TTL = 1.day

    def initialize(user, template_key: "welcome")
      @user = user
      @template_key = template_key
    end

    def self.clear_all_data!(user)
      user.habits.destroy_all
      user.medications.destroy_all
      user.biometric_metrics.destroy_all
      user.agenda_items.destroy_all
      user.lab_panels.destroy_all
      BiometricEntry.where(user_id: user.id).delete_all
    end

    def call
      ActiveRecord::Base.transaction do
        self.class.clear_all_data!(@user)
        Templates::Applier.new(@user, @template_key, force: true).call
        @user.update!(data_resets_at: TTL.from_now)
      end
      @user
    end
  end
end
