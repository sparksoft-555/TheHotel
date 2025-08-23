class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :price_at_time, precision: 8, scale: 2, null: false
      t.text :customizations

      t.timestamps
    end

    add_index :order_items, [ :order_id, :menu_item_id ]
  end
end
