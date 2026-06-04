module LabResults
  class DueExpander < ApplicationService
    def initialize(user:, on_date:, results_by_date: nil)
      @user = user
      @on_date = on_date
      @results_by_date = results_by_date
    end

    def call
      results = if @results_by_date
        @results_by_date[@on_date] || []
      else
        LabResult.includes(:lab_panel)
                 .where(due_on: @on_date, completed_on: nil)
                 .where(lab_panels: { user_id: @user.id })
                 .references(:lab_panel)
      end

      results.map do |result|
        Agenda::DayComposer::Entry.new(
          source: :lab_result,
          id: result.id,
          title: result.lab_panel.name,
          scheduled_at_minute: nil,
          duration_minutes: nil,
          category: "medical",
          color_hue: 200,
          completed: result.completed_on.present?,
          record: result
        )
      end
    end
  end
end
