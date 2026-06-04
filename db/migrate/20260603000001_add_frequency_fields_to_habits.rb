class AddFrequencyFieldsToHabits < ActiveRecord::Migration[8.0]
  def up
    add_column :habits, :occurs_on,     :date
    add_column :habits, :weekly_target, :integer
    add_column :habits, :monthly_day,   :integer

    # Backfill: unify legacy 'weekly' and 'custom_days' -> 'weekly_days'
    execute <<~SQL
      UPDATE habits SET frequency_type = 'weekly_days',
        recurrence_days = ARRAY[1,2,3,4,5,6,7]
      WHERE frequency_type = 'weekly'
    SQL
    execute <<~SQL
      UPDATE habits SET frequency_type = 'weekly_days'
      WHERE frequency_type = 'custom_days'
    SQL
  end

  def down
    remove_column :habits, :occurs_on
    remove_column :habits, :weekly_target
    remove_column :habits, :monthly_day
  end
end
