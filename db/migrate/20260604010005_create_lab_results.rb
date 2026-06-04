class CreateLabResults < ActiveRecord::Migration[8.0]
  def change
    create_table :lab_results do |t|
      t.belongs_to :lab_panel, null: false, foreign_key: true
      t.date :due_on
      t.date :completed_on
      t.text :result_summary
      t.timestamps
    end
    add_index :lab_results, [:lab_panel_id, :completed_on]
    add_index :lab_results, :due_on
  end
end
