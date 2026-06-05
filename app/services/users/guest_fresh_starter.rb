module Users
  class GuestFreshStarter < ApplicationService
    def initialize(user)
      @user = user
    end

    def call
      ActiveRecord::Base.transaction do
        GuestResetter.clear_all_data!(@user)
        @user.update!(
          data_resets_at: GuestResetter::TTL.from_now,
          template_key: nil,
          template_applied_at: nil
        )
      end
      @user
    end
  end
end
