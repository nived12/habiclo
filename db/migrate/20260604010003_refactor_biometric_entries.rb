class RefactorBiometricEntries < ActiveRecord::Migration[8.0]
  def up
    # Reset approach (decisión del usuario): truncate datos viejos y reestructura.
    execute "TRUNCATE TABLE biometric_entries RESTART IDENTITY"
    remove_index :biometric_entries, name: "index_biometric_entries_on_user_id_and_metric_and_recorded_on"
    remove_column :biometric_entries, :metric
    add_reference :biometric_entries, :biometric_metric, null: false, foreign_key: true
    add_index :biometric_entries, [ :biometric_metric_id, :recorded_on ],
              name: "index_biometric_entries_on_metric_and_date"
  end

  def down
    remove_index :biometric_entries, name: "index_biometric_entries_on_metric_and_date"
    remove_reference :biometric_entries, :biometric_metric, foreign_key: true
    add_column :biometric_entries, :metric, :string, null: false, default: "weight_kg"
    change_column_default :biometric_entries, :metric, nil
    add_index :biometric_entries, [ :user_id, :metric, :recorded_on ],
              name: "index_biometric_entries_on_user_id_and_metric_and_recorded_on"
  end
end
