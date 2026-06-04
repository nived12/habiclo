module Medications
  class DoseExpander < ApplicationService
    def initialize(user:, on_date:, meds: nil, intakes_set: nil)
      @user = user
      @on_date = on_date
      @meds = meds
      @intakes_set = intakes_set
    end

    def call
      meds = @meds || @user.medications.includes(:medication_intakes)
      meds.flat_map do |med|
        (med.schedule_minutes || []).map do |minute|
          completed = @intakes_set ? @intakes_set.include?([med.id, @on_date, minute]) : med.taken_on?(@on_date, minute)
          Agenda::DayComposer::Entry.new(
            source: :medication_dose,
            id: "med_#{med.id}_#{minute}",
            title: "#{med.name} #{med.dose}".strip,
            scheduled_at_minute: minute,
            duration_minutes: 5,
            category: "medical",
            color_hue: 320,
            completed: completed,
            record: med
          )
        end
      end
    end
  end
end
