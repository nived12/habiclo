class CreateBiometricMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :biometric_metrics do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :unit
      t.string :category
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :biometric_metrics, [:user_id, :name], unique: true
    add_index :biometric_metrics, [:user_id, :position]
  end
end
