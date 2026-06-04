class HabitCompletionsController < ApplicationController
  before_action :set_habit

  def new
    @on_date = parse_date(params[:on]) || today
    @existing = @habit.habit_completions.find_by(completed_on: @on_date)
    @completion = @existing || @habit.habit_completions.new(
      completed_on: @on_date,
      completed_at_minute: Time.current.in_time_zone(current_or_guest_user.time_zone).then { |t| t.hour * 60 + t.min },
      value: @existing&.value || @habit.target_value
    )
  end

  def create
    @on_date = parse_date(params[:on]) || today
    @completion = @habit.habit_completions.find_or_initialize_by(completed_on: @on_date)
    @completion.assign_attributes(completion_params)
    @completion.save!
    maybe_create_biometric_entry!(@completion)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("log_modal", ""),
          turbo_stream.replace("habit_block_#{@habit.id}_#{@on_date.iso8601}",
            partial: "agenda/block",
            locals: { entry: rebuild_entry(@habit, @on_date), on_date: @on_date, compact: params[:compact] != "false" })
        ]
      end
      format.html { redirect_to root_path }
    end
  end

  def toggle
    on_date = parse_date(params[:on]) || today
    result = Habits::ToggleCompleter.call(habit: @habit, on_date: on_date)
    compact = params[:compact] != "false"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "habit_block_#{@habit.id}_#{on_date.iso8601}",
          partial: "agenda/block",
          locals: { entry: rebuild_entry(result.value[:habit], on_date), on_date: on_date, compact: compact }
        )
      end
      format.json { render json: { strength: result.value[:strength], completed: result.value[:completion].present? } }
      format.html { redirect_to root_path }
    end
  end

  def destroy
    toggle
  end

  private

  def completion_params
    params.require(:habit_completion).permit(:value, :notes, :completed_at_minute).tap do |p|
      p[:completed_at_minute] = parse_time_to_minute(p[:completed_at_minute]) if p.key?(:completed_at_minute)
    end
  end

  def parse_time_to_minute(value)
    return value if value.is_a?(Integer)
    return nil if value.blank?
    if value.to_s.match?(/\A\d{1,2}:\d{2}\z/)
      h, m = value.split(":").map(&:to_i)
      h * 60 + m
    else
      value.to_i
    end
  end

  # Si el habit.unit corresponde a una métrica biométrica conocida y el usuario YA tiene
  # una BiometricMetric con ese nombre canónico, registramos también el valor en su historial.
  # No auto-crea métricas — silencio si no existe.
  BIOMETRIC_UNIT_MAP = {
    "kg"      => "Peso",
    "cm"      => "Cintura",
    "mmhg"    => "Tensión sistólica",
    "hours"   => "Sueño",
    "h"       => "Sueño",
    "minutes" => "Minutos aeróbicos",
    "min"     => "Minutos aeróbicos",
    "bpm"     => "Frec. cardiaca reposo",
    "%"       => "% grasa corporal"
  }.freeze

  def maybe_create_biometric_entry!(completion)
    return unless completion.value.present? && completion.value > 0
    canonical_name = BIOMETRIC_UNIT_MAP[@habit.unit.to_s.strip.downcase]
    return unless canonical_name

    metric = current_or_guest_user.biometric_metrics
                                  .where("LOWER(name) = ?", canonical_name.downcase).first
    return unless metric

    metric.biometric_entries.create!(
      user: current_or_guest_user,
      value: completion.value,
      recorded_on: completion.completed_on,
      recorded_at_minute: completion.completed_at_minute,
      source: "habit"
    )
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def set_habit
    @habit = current_or_guest_user.habits.find(params[:habit_id])
  end

  def today
    Time.current.in_time_zone(current_or_guest_user.time_zone).to_date
  end

  def parse_date(value)
    Date.parse(value) if value.present?
  rescue ArgumentError
    nil
  end

  def rebuild_entry(habit, on_date)
    Agenda::DayComposer::Entry.new(
      source: :habit,
      id: habit.id,
      title: habit.name,
      scheduled_at_minute: habit.scheduled_at_minute,
      duration_minutes: habit.duration_minutes,
      category: habit.category,
      color_hue: habit.color_hue,
      completed: habit.completed_on?(on_date),
      record: habit
    )
  end
end
