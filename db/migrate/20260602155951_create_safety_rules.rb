class CreateSafetyRules < ActiveRecord::Migration[8.0]
  def change
    create_table :safety_rules do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.boolean :enabled, null: false, default: true
      t.text :context_note

      t.timestamps
    end

    add_index :safety_rules, [ :user_id, :kind ], unique: true
  end
end
