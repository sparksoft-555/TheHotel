class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: 'customer'
      t.string :phone
      t.text :address
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
