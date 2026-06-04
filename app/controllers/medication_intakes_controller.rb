class MedicationIntakesController < ApplicationController
  before_action :set_medication

  def toggle
    on_date = parse_date(params[:on]) || today
    minute  = params[:minute].to_i if params[:minute].present?
    compact = params[:compact] != "false"

    taken = @medication.toggle_intake!(on_date, minute)

    entry = Agenda::DayComposer::Entry.new(
      source: :medication_dose,
      id: "med_#{@medication.id}_#{minute}",
      title: "#{@medication.name} #{@medication.dose}".strip,
      scheduled_at_minute: minute,
      duration_minutes: 5,
      category: "medical",
      color_hue: 320,
      completed: taken,
      record: @medication
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "habit_block_med_#{@medication.id}_#{minute}_#{on_date.iso8601}",
          partial: "agenda/block",
          locals: { entry: entry, on_date: on_date, compact: compact }
        )
      end
      format.html { redirect_to root_path }
    end
  end

  private

  def set_medication
    @medication = current_or_guest_user.medications.find(params[:medication_id])
  end

  def today
    Time.current.in_time_zone(current_or_guest_user.time_zone).to_date
  end

  def parse_date(value)
    Date.parse(value) if value.present?
  rescue ArgumentError
    nil
  end
end
