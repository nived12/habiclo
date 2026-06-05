module Agenda
  class DayComposer < ApplicationService
    Entry = Struct.new(
      :source, :id, :title, :scheduled_at_minute, :duration_minutes,
      :category, :color_hue, :completed, :record,
      keyword_init: true
    ) do
      def floating? = scheduled_at_minute.nil?
      def end_minute = scheduled_at_minute && scheduled_at_minute + (duration_minutes || 30)
    end

    def initialize(user:, on_date:, habits: nil, completions_map: nil,
                   all_completions_map: nil, meds: nil, intakes_set: nil,
                   agenda_items_by_date: nil, lab_results_by_date: nil)
      @user = user
      @on_date = on_date
      @habits = habits
      @completions_map = completions_map
      @all_completions_map = all_completions_map
      @meds = meds
      @intakes_set = intakes_set
      @agenda_items_by_date = agenda_items_by_date
      @lab_results_by_date = lab_results_by_date
    end

    def call
      entries = []
      entries.concat(habit_entries)
      entries.concat(agenda_item_entries)
      entries.concat(medication_entries)
      entries.concat(lab_result_entries)
      entries.sort_by { |e| [ e.scheduled_at_minute || 1500, e.title.to_s ] }
    end

    private

    def habit_entries
      habits = @habits || @user.habits.ordered.includes(:habit_completions)
      habits.filter_map do |habit|
        next unless habit.scheduled_for?(@on_date)

        completed = @completions_map ? (@completions_map[habit.id]&.include?(@on_date) || false) : habit.completed_on?(@on_date)
        Entry.new(
          source: :habit,
          id: habit.id,
          title: habit.name,
          scheduled_at_minute: habit.scheduled_at_minute,
          duration_minutes: habit.duration_minutes,
          category: habit.category,
          color_hue: habit.color_hue,
          completed: completed,
          record: habit
        )
      end
    end

    def agenda_item_entries
      items = @agenda_items_by_date ? (@agenda_items_by_date[@on_date] || []) : @user.agenda_items.where(occurs_on: @on_date)
      items.map do |item|
        Entry.new(
          source: :agenda_item,
          id: item.id,
          title: item.title,
          scheduled_at_minute: item.scheduled_at_minute,
          duration_minutes: item.duration_minutes,
          category: item.kind,
          color_hue: 220,
          completed: false,
          record: item
        )
      end
    end

    def medication_entries
      Medications::DoseExpander.call(user: @user, on_date: @on_date, meds: @meds, intakes_set: @intakes_set)
    end

    def lab_result_entries
      LabResults::DueExpander.call(user: @user, on_date: @on_date, results_by_date: @lab_results_by_date)
    end
  end
end
