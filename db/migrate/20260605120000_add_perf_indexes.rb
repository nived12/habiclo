class AddPerfIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :medication_intakes, [:taken_on, :medication_id], name: "idx_med_intakes_date_med"
    add_index :biometric_entries,  [:user_id, :recorded_on],    name: "idx_biometric_entries_user_date"
  end
end
