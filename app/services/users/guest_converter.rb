module Users
  class GuestConverter < ApplicationService
    def initialize(guest:, target:)
      @guest = guest
      @target = target
    end

    def call
      return failure(:not_a_guest) unless @guest&.guest?
      return failure(:target_required) unless @target&.persisted?

      ActiveRecord::Base.transaction do
        Habit.where(user_id: @guest.id).update_all(user_id: @target.id)
        AgendaItem.where(user_id: @guest.id).update_all(user_id: @target.id)
        BiometricEntry.where(user_id: @guest.id).update_all(user_id: @target.id)
        Medication.where(user_id: @guest.id).update_all(user_id: @target.id)
        LabPanel.where(user_id: @guest.id).update_all(user_id: @target.id)
        BiometricMetric.where(user_id: @guest.id).update_all(user_id: @target.id)

        @guest.delete
      end

      success(@target.reload)
    end
  end
end
