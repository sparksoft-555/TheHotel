class CreateWorkLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :work_logs do |t|
      t.references :employee, null: false, foreign_key: { to_table: :users }
      t.datetime :clock_in, null: false
      t.datetime :clock_out
      t.boolean :approved, default: false
      t.text :notes
      t.decimal :break_duration, precision: 4, scale: 2, default: 0
      
      t.timestamps
    end
    
    add_index :work_logs, :employee_id
    add_index :work_logs, :clock_in
    add_index :work_logs, :approved
  end
end