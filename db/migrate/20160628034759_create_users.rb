class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :email, null: false
      t.string :name, null: false
      t.string :quote
      t.integer :user_type, null: false

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
