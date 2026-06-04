module AgendaHelper
  def completion_ratio_for(entries)
    habit_entries = entries.select { |e| e.source == :habit }
    return nil if habit_entries.empty?
    completed = habit_entries.count(&:completed)
    { completed: completed, total: habit_entries.size, pct: (completed.to_f / habit_entries.size * 100).round }
  end

  # 7-day completion booleans for the habit ending on the given date.
  # Pass `all_completions_map` (Hash[habit_id => Array<[date, value]>]) to avoid a DB query per habit.
  def habit_recent_pattern(habit, on_date, days: 7, all_completions_map: nil)
    range = (on_date - (days - 1).days)..on_date
    completed = if all_completions_map && all_completions_map[habit.id]
      all_completions_map[habit.id].map(&:first).to_set
    else
      habit.habit_completions.where(completed_on: range).pluck(:completed_on).to_set
    end
    range.map { |d| completed.include?(d) }
  end
end
