class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :customer, null: true, foreign_key: { to_table: :users }
      t.string :table_number, null: false
      t.string :status, default: 'received'
      t.text :special_instructions
      t.datetime :estimated_completion
      
      t.timestamps
    end
    
    add_index :orders, :status
    add_index :orders, :table_number
    add_index :orders, :created_at
  end
end