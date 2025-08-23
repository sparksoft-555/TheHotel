class CreateBills < ActiveRecord::Migration[7.0]
  def change
    create_table :bills do |t|
      t.references :order, null: false, foreign_key: true
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :payment_status, default: 'pending'
      t.string :payment_method
      t.datetime :paid_at
      t.text :notes
      t.decimal :tip_amount, precision: 8, scale: 2, default: 0
      t.decimal :discount_amount, precision: 8, scale: 2, default: 0
      
      t.timestamps
    end
    
    add_index :bills, :payment_status
    add_index :bills, :paid_at
    add_index :bills, :order_id, unique: true
  end
end