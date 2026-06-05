module Users
  class GuestConverter < ApplicationService
    ConverterResult = Struct.new(:success, :target, :counts, keyword_init: true) do
      def success? = success
    end

    def initialize(guest:, target:)
      @guest = guest
      @target = target
    end

    def call
      return ConverterResult.new(success: false) unless @guest&.guest? && @target&.persisted?

      counts = nil
      ActiveRecord::Base.transaction do
        counts = compute_counts
        Habit.where(user_id: @guest.id).update_all(user_id: @target.id)
        AgendaItem.where(user_id: @guest.id).update_all(user_id: @target.id)
        BiometricEntry.where(user_id: @guest.id).update_all(user_id: @target.id)
        Medication.where(user_id: @guest.id).update_all(user_id: @target.id)
        LabPanel.where(user_id: @guest.id).update_all(user_id: @target.id)
        BiometricMetric.where(user_id: @guest.id).update_all(user_id: @target.id)

        @target.update!(
          data_resets_at: nil,
          help_seen_at: @guest.help_seen_at || @target.help_seen_at
        )
        @guest.delete
      end

      ConverterResult.new(success: true, target: @target.reload, counts: counts)
    end

    private

    def compute_counts
      habit_ids = @guest.habits.pluck(:id)
      {
        habits: habit_ids.size,
        completions: HabitCompletion.where(habit_id: habit_ids).count,
        medications: @guest.medications.count,
        biometric_metrics: @guest.biometric_metrics.count,
        biometric_entries: @guest.biometric_entries.count
      }
    end
  end
end
