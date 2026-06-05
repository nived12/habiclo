class AddOnboardingFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :help_seen_at, :datetime
    add_column :users, :template_key, :string
    add_column :users, :template_applied_at, :datetime
    add_column :users, :data_resets_at, :datetime

    add_index :users, :data_resets_at
  end
end
