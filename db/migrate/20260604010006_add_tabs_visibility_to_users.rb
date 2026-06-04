class AddTabsVisibilityToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :tabs_visibility, :jsonb, null: false, default: {}
  end
end
