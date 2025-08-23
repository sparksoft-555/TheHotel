class CreateInventoryItems < ActiveRecord::Migration[7.0]
  def change
    create_table :inventory_items do |t|
      t.string :name, null: false
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.string :unit, null: false
      t.string :category, null: false
      t.date :expiry_date
      t.decimal :minimum_quantity, precision: 10, scale: 2
      t.decimal :cost_per_unit, precision: 8, scale: 2
      t.string :supplier
      t.text :notes
      
      t.timestamps
    end
    
    add_index :inventory_items, :category
    add_index :inventory_items, :expiry_date
    add_index :inventory_items, :name
  end
end