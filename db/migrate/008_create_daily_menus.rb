class CreateDailyMenus < ActiveRecord::Migration[7.0]
  def change
    create_table :daily_menus do |t|
      t.date :menu_date, null: false
      t.text :special_notes
      t.boolean :active, default: true
      
      t.timestamps
    end
    
    add_index :daily_menus, :menu_date, unique: true
    add_index :daily_menus, :active
  end
end