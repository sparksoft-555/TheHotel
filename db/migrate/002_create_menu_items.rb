class CreateMenuItems < ActiveRecord::Migration[7.0]
  def change
    create_table :menu_items do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 8, scale: 2, null: false
      t.string :category, null: false
      t.boolean :available, default: true
      t.text :ingredients
      t.string :dietary_info # vegetarian, vegan, gluten-free, etc.
      t.integer :prep_time_minutes

      t.timestamps
    end

    add_index :menu_items, :category
    add_index :menu_items, :available
  end
end
