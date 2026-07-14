class AddHiddenFromDashboardToHabits < ActiveRecord::Migration[8.0]
  def change
    add_column :habits, :hidden_from_dashboard, :boolean, default: false, null: false
  end
end
