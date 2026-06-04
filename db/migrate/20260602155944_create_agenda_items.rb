class CreateAgendaItems < ActiveRecord::Migration[8.0]
  def change
    create_table :agenda_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :notes
      t.date :occurs_on, null: false
      t.integer :scheduled_at_minute
      t.integer :duration_minutes
      t.string :kind, null: false, default: "event"
      t.string :linked_type
      t.bigint :linked_id
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :agenda_items, [:user_id, :occurs_on]
    add_index :agenda_items, [:linked_type, :linked_id]
    add_index :agenda_items, :discarded_at
  end
end
