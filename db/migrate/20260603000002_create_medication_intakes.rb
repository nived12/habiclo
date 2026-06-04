class CreateMedicationIntakes < ActiveRecord::Migration[8.0]
  def change
    create_table :medication_intakes do |t|
      t.references :medication, null: false, foreign_key: true
      t.date    :taken_on,         null: false
      t.integer :scheduled_minute
      t.integer :taken_at_minute
      t.text    :notes
      t.timestamps
    end

    add_index :medication_intakes, [:medication_id, :taken_on, :scheduled_minute],
              unique: true, name: "idx_med_intakes_unique"
  end
end
