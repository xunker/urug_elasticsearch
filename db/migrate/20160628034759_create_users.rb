class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :email, null: false
      t.text :name, null: false
      t.text :quote
      t.integer :quote_type, null: false

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
