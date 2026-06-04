class CreateHabits < ActiveRecord::Migration[8.0]
  def change
    create_table :habits do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :frequency_type, null: false, default: "daily"
      t.integer :recurrence_days, array: true, default: [], null: false
      t.decimal :target_value, precision: 10, scale: 2, default: 1.0, null: false
      t.string :unit, null: false, default: "times"
      t.string :category, null: false, default: "general"
      t.integer :color_hue, null: false, default: 25
      t.integer :position, null: false, default: 0
      t.integer :scheduled_at_minute
      t.integer :duration_minutes
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :habits, [:user_id, :position]
    add_index :habits, :discarded_at
  end
end
