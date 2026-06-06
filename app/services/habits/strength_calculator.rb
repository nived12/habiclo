module Habits
  # Exponential-decay habit strength.
  # S_t = (1 - L)^gap * S_{t-1} + G * C_t * (1 - S_{t-1})
  # where gap = days since the prior considered date.
  class StrengthCalculator < ApplicationService
    LAMBDA = 0.05
    GAMMA  = 0.10

    def initialize(habit:, on_date: nil, completions: nil)
      @habit = habit
      @on_date = on_date || habit.user.then { |u| Time.current.in_time_zone(u.time_zone).to_date }
      @preloaded_completions = completions
    end

    def call
      compute
    end

    private

    def compute
      first_seen = @habit.created_at.in_time_zone(@habit.user.time_zone).to_date
      return 0.0 if @on_date < first_seen

      completions = if @preloaded_completions
        @preloaded_completions
          .select { |date, _v| date <= @on_date }
          .sort_by(&:first)
      else
        @habit.habit_completions
              .where("completed_on <= ?", @on_date)
              .order(:completed_on)
              .pluck(:completed_on, :value)
      end

      strength = 0.0
      cursor = first_seen
      idx = 0
      while cursor <= @on_date
        gap = (cursor - (idx.zero? ? cursor : cursor - 1)).to_i
        decay = (1.0 - LAMBDA)**gap

        c_value = 0.0
        if completions[idx]&.first == cursor
          target = @habit.target_value.to_f.nonzero? || 1.0
          c_value = [ completions[idx].last.to_f / target, 1.0 ].min
          idx += 1
        end

        strength = decay * strength + GAMMA * c_value * (1.0 - strength)
        cursor += 1
      end

      strength.round(4)
    end
  end
end
