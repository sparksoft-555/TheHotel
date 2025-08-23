class CreateDailyMenuItems < ActiveRecord::Migration[7.0]
  def change
    create_table :daily_menu_items do |t|
      t.references :daily_menu, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.boolean :featured, default: false
      t.integer :display_order

      t.timestamps
    end

    add_index :daily_menu_items, [ :daily_menu_id, :menu_item_id ], unique: true
    add_index :daily_menu_items, :featured
  end
end
