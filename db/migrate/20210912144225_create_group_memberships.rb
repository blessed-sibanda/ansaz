class CreateGroupMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :group_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.string :state

      t.timestamps
    end
    add_index :group_memberships, [:user_id, :group_id], unique: true
  end
end
