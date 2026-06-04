class RemoveDiscardedAtColumns < ActiveRecord::Migration[8.0]
  def change
    remove_index :habits,        name: "index_habits_on_discarded_at"
    remove_index :medications,   name: "index_medications_on_discarded_at"
    remove_index :agenda_items,  name: "index_agenda_items_on_discarded_at"

    remove_column :habits,        :discarded_at, :datetime
    remove_column :medications,   :discarded_at, :datetime
    remove_column :agenda_items,  :discarded_at, :datetime
  end
end
