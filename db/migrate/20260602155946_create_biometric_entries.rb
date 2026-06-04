class CreateBiometricEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :biometric_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :recorded_on, null: false
      t.integer :recorded_at_minute
      t.string :metric, null: false
      t.decimal :value, precision: 12, scale: 3, null: false
      t.string :source, null: false, default: "manual"

      t.timestamps
    end

    add_index :biometric_entries, [:user_id, :metric, :recorded_on]
  end
end
