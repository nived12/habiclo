class CreateLabPanels < ActiveRecord::Migration[8.0]
  def change
    create_table :lab_panels do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.date :due_on, null: false
      t.date :completed_on
      t.text :result_summary

      t.timestamps
    end

    add_index :lab_panels, [:user_id, :due_on]
  end
end
