module Habits
  class ToggleCompleter < ApplicationService
    def initialize(habit:, on_date:, at_minute: nil)
      @habit = habit
      @on_date = on_date
      @at_minute = at_minute
    end

    def call
      completion = @habit.habit_completions.find_by(completed_on: @on_date)
      if completion
        completion.destroy!
        result(nil)
      else
        completion = @habit.habit_completions.create!(
          completed_on: @on_date,
          completed_at_minute: @at_minute,
          value: @habit.target_value
        )
        result(completion)
      end
    end

    private

    def result(completion)
      strength = Habits::StrengthCalculator.call(habit: @habit, on_date: @on_date)
      success(habit: @habit, completion: completion, strength: strength)
    end
  end
end
