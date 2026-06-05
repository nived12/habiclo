class AgendaController < ApplicationController
  def index
    redirect_to agenda_week_path(on: today.iso8601)
  end

  def week
    @on_date = parse_date(:on) || today
    @focused_day = parse_date(:focus) || @on_date.then do |d|
      d == @on_date.beginning_of_week(:monday) ? today : (today.between?(
        @on_date.beginning_of_week(:monday),
        @on_date.end_of_week(:monday)
      ) ? today : @on_date)
    end
    @week_start = @on_date.beginning_of_week(:monday)
    @days = (0..6).map { |i| @week_start + i }
    @pre = preload_range(current_or_guest_user, @week_start, @week_start + 6)
    @entries_by_day = @days.index_with { |d| Agenda::DayComposer.call(user: current_or_guest_user, on_date: d, **@pre) }
    @focused_entries = @entries_by_day[@focused_day] || Agenda::DayComposer.call(
      user: current_or_guest_user,
      on_date: @focused_day, **@pre
    )
    @today = today
  end

  def month
    @on_date = parse_date(:on) || today
    @month_start = @on_date.beginning_of_month
    @month_end = @on_date.end_of_month
    @days = (@month_start..@month_end).to_a
    @pre = preload_range(current_or_guest_user, @month_start, @month_end)
    @entries_by_day = @days.index_with { |d| Agenda::DayComposer.call(user: current_or_guest_user, on_date: d, **@pre) }
    @today = today
  end

  def day
    @on_date = parse_date(:on) || today
    @pre = preload_range(current_or_guest_user, @on_date, @on_date)
    @entries = Agenda::DayComposer.call(user: current_or_guest_user, on_date: @on_date, **@pre)
    @scheduled  = @entries.reject(&:floating?)
    @floating   = @entries.select(&:floating?)
    @today = today
    load_day_vitals
  end

  private

  def preload_range(user, from, to)
    habits = user.habits.ordered.to_a
    habit_ids = habits.map(&:id)

    # In-range Set of dates per habit — for completed_on? checks
    completions_map = HabitCompletion
      .where(habit_id: habit_ids, completed_on: from..to)
      .group_by(&:habit_id)
      .transform_values { |cs| cs.map(&:completed_on).to_set }

    # All-time tuples per habit — for StrengthCalculator (needs full history)
    all_completions_map = HabitCompletion
      .where(habit_id: habit_ids)
      .pluck(:habit_id, :completed_on, :value)
      .group_by(&:first)
      .transform_values { |rows| rows.map { |_id, d, v| [ d, v ] } }

    meds = user.medications.to_a
    intakes_set = MedicationIntake
      .where(medication_id: meds.map(&:id), taken_on: from..to)
      .each_with_object(Set.new) { |i, s| s.add([ i.medication_id, i.taken_on, i.scheduled_minute ]) }

    # Pre-grouped agenda items by date (avoids 1 query per day in DayComposer)
    agenda_items_by_date = user.agenda_items
      .where(occurs_on: from..to)
      .group_by(&:occurs_on)

    # Pending lab results in range — for LabResults::DueExpander
    lab_results_by_date = LabResult
      .includes(:lab_panel)
      .where(completed_on: nil, due_on: from..to)
      .where(lab_panels: { user_id: user.id })
      .references(:lab_panel)
      .group_by(&:due_on)

    {
      habits: habits,
      completions_map: completions_map,
      all_completions_map: all_completions_map,
      meds: meds,
      intakes_set: intakes_set,
      agenda_items_by_date: agenda_items_by_date,
      lab_results_by_date: lab_results_by_date
    }
  end

  def today
    Time.current.in_time_zone(current_or_guest_user.time_zone).to_date
  end

  def parse_date(key)
    Date.parse(params[key]) if params[key].present?
  rescue ArgumentError
    nil
  end

  def load_day_vitals
    user = current_or_guest_user
    @log_metric = user.biometric_metrics.ordered.first
    @recent_biometrics = user.biometric_entries
      .includes(:biometric_metric)
      .where(recorded_on: ..@on_date)
      .order(recorded_on: :desc)
      .limit(6)
  end
end
