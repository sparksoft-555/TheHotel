class EnhanceHotelManagementSystem < ActiveRecord::Migration[7.1]
  def change
    # Add new fields to orders table for kitchen workflow
    add_column :orders, :started_cooking_at, :datetime
    add_column :orders, :ready_at, :datetime
    
    # Add new fields to bills table for enhanced payment tracking
    add_column :bills, :tax_amount, :decimal, precision: 10, scale: 2
    add_column :bills, :service_charge, :decimal, precision: 10, scale: 2
    add_column :bills, :final_amount, :decimal, precision: 10, scale: 2
    add_column :bills, :amount_received, :decimal, precision: 10, scale: 2
    add_column :bills, :change_amount, :decimal, precision: 10, scale: 2
    
    # Rename payment_status to status in bills table for consistency
    if column_exists?(:bills, :payment_status)
      rename_column :bills, :payment_status, :status
    end
    
    # Add new fields to menu_items table
    add_column :menu_items, :estimated_prep_time, :integer, comment: 'Estimated preparation time in minutes'
    unless column_exists?(:menu_items, :ingredients)
      add_column :menu_items, :ingredients, :text, comment: 'Comma-separated list of ingredients'
    end
    
    # Add new fields to users table if not exists
    unless column_exists?(:users, :name)
      add_column :users, :name, :string
    end
    
    # Add new fields to inventory_items table if needed
    unless column_exists?(:inventory_items, :minimum_quantity)
      add_column :inventory_items, :minimum_quantity, :integer, default: 10
    end
    
    unless column_exists?(:inventory_items, :expiry_date)
      add_column :inventory_items, :expiry_date, :date
    end
    
    # Add new fields to work_logs table if needed
    unless column_exists?(:work_logs, :hourly_rate)
      add_column :work_logs, :hourly_rate, :decimal, precision: 8, scale: 2
    end
  end
end