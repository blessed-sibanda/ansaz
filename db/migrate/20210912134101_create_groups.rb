class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.bigint :admin_id
      t.string :group_type

      t.timestamps
    end
    add_index :groups, :name, unique: true
    add_foreign_key :groups, :users, column: :admin_id
  end
end
