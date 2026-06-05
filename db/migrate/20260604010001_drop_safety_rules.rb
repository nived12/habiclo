class DropSafetyRules < ActiveRecord::Migration[8.0]
  def up
    drop_table :safety_rules
  end

  def down
    create_table :safety_rules do |t|
      t.bigint :user_id, null: false
      t.string :kind, null: false
      t.boolean :enabled, default: true, null: false
      t.text :context_note
      t.timestamps
      t.index [ :user_id, :kind ], unique: true
      t.index :user_id
    end
    add_foreign_key :safety_rules, :users
  end
end
