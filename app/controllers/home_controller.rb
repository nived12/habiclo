class HomeController < ApplicationController
  def show
    @user = current_or_guest_user
    tz   = @user.time_zone
    today = Time.current.in_time_zone(tz).to_date

    @year  = (params[:year]  || today.year).to_i
    @month = (params[:month] || today.month).to_i
    @today = today

    @month_start = Date.new(@year, @month, 1)
    @month_end   = @month_start.end_of_month
    @days        = (@month_start..@month_end).to_a

    habits = @user.habits.ordered

    @daily_habits   = habits.select { |h| h.frequency_type == "daily" }
    @weekly_habits  = habits.select { |h| %w[weekly_days x_per_week].include?(h.frequency_type) }
    @monthly_habits = habits.select { |h| h.frequency_type == "monthly" }

    # Preload completions for the month (date Sets — for ring fill checks)
    all_habit_ids = (@daily_habits + @weekly_habits + @monthly_habits).map(&:id)
    completions = HabitCompletion.where(
      habit_id: all_habit_ids,
      completed_on: @month_start..@month_end
    )
    @completions_map = completions.group_by(&:habit_id).transform_values do |comps|
      comps.map(&:completed_on).to_set
    end

    # All-time completion tuples per habit — for StrengthCalculator without N+1
    all_completions_map = HabitCompletion
      .where(habit_id: @daily_habits.map(&:id))
      .pluck(:habit_id, :completed_on, :value)
      .group_by(&:first)
      .transform_values { |rows| rows.map { |_id, d, v| [d, v] } }

    # Precompute strength % per daily habit at @today — used by legend
    @strengths_map = @daily_habits.index_with do |habit|
      (Habits::StrengthCalculator.call(
        habit: habit,
        on_date: @today,
        completions: all_completions_map[habit.id] || []
      ) * 100).round
    end

    # Weekly: build week columns for the month
    @week_starts = []
    d = @month_start.beginning_of_week(:monday)
    while d <= @month_end
      @week_starts << d
      d += 7
    end
  end
end
