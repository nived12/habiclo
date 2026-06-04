class CreateMedications < ActiveRecord::Migration[8.0]
  def change
    create_table :medications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :dose
      t.integer :schedule_minutes, array: true, default: [], null: false
      t.text :notes
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :medications, :discarded_at
  end
end
