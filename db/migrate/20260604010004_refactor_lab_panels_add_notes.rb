class RefactorLabPanelsAddNotes < ActiveRecord::Migration[8.0]
  def up
    # Reset approach: limpiar paneles viejos (incluyendo sus campos result/due/completed).
    execute "TRUNCATE TABLE lab_panels RESTART IDENTITY CASCADE"
    remove_index :lab_panels, name: "index_lab_panels_on_user_id_and_due_on"
    remove_column :lab_panels, :due_on
    remove_column :lab_panels, :completed_on
    remove_column :lab_panels, :result_summary
    add_column :lab_panels, :notes, :text
    add_column :lab_panels, :position, :integer, null: false, default: 0
    add_index :lab_panels, [ :user_id, :position ]
  end

  def down
    remove_index :lab_panels, [ :user_id, :position ]
    remove_column :lab_panels, :position
    remove_column :lab_panels, :notes
    add_column :lab_panels, :result_summary, :text
    add_column :lab_panels, :completed_on, :date
    add_column :lab_panels, :due_on, :date, null: false, default: -> { "CURRENT_DATE" }
    change_column_default :lab_panels, :due_on, nil
    add_index :lab_panels, [ :user_id, :due_on ]
  end
end
