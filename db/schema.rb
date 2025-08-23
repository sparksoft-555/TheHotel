# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 9) do
  create_table "bills", force: :cascade do |t|
    t.integer "order_id", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.string "payment_status", default: "pending"
    t.string "payment_method"
    t.datetime "paid_at"
    t.text "notes"
    t.decimal "tip_amount", precision: 8, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 8, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_bills_on_order_id"
    t.index ["paid_at"], name: "index_bills_on_paid_at"
    t.index ["payment_status"], name: "index_bills_on_payment_status"
  end

  create_table "daily_menu_items", force: :cascade do |t|
    t.integer "daily_menu_id", null: false
    t.integer "menu_item_id", null: false
    t.boolean "featured", default: false
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_menu_id", "menu_item_id"], name: "index_daily_menu_items_on_daily_menu_id_and_menu_item_id", unique: true
    t.index ["daily_menu_id"], name: "index_daily_menu_items_on_daily_menu_id"
    t.index ["featured"], name: "index_daily_menu_items_on_featured"
    t.index ["menu_item_id"], name: "index_daily_menu_items_on_menu_item_id"
  end

  create_table "daily_menus", force: :cascade do |t|
    t.date "menu_date", null: false
    t.text "special_notes"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_daily_menus_on_active"
    t.index ["menu_date"], name: "index_daily_menus_on_menu_date", unique: true
  end

  create_table "inventory_items", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.string "unit", null: false
    t.string "category", null: false
    t.date "expiry_date"
    t.decimal "minimum_quantity", precision: 10, scale: 2
    t.decimal "cost_per_unit", precision: 8, scale: 2
    t.string "supplier"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_inventory_items_on_category"
    t.index ["expiry_date"], name: "index_inventory_items_on_expiry_date"
    t.index ["name"], name: "index_inventory_items_on_name"
  end

  create_table "menu_items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 8, scale: 2, null: false
    t.string "category", null: false
    t.boolean "available", default: true
    t.text "ingredients"
    t.string "dietary_info"
    t.integer "prep_time_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available"], name: "index_menu_items_on_available"
    t.index ["category"], name: "index_menu_items_on_category"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "menu_item_id", null: false
    t.integer "quantity", null: false
    t.decimal "price_at_time", precision: 8, scale: 2, null: false
    t.text "customizations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id"], name: "index_order_items_on_menu_item_id"
    t.index ["order_id", "menu_item_id"], name: "index_order_items_on_order_id_and_menu_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "customer_id"
    t.string "table_number", null: false
    t.string "status", default: "received"
    t.text "special_instructions"
    t.datetime "estimated_completion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["table_number"], name: "index_orders_on_table_number"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "customer", null: false
    t.string "phone"
    t.text "address"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "work_logs", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.datetime "clock_in", null: false
    t.datetime "clock_out"
    t.boolean "approved", default: false
    t.text "notes"
    t.decimal "break_duration", precision: 4, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved"], name: "index_work_logs_on_approved"
    t.index ["clock_in"], name: "index_work_logs_on_clock_in"
    t.index ["employee_id"], name: "index_work_logs_on_employee_id"
  end

  add_foreign_key "bills", "orders"
  add_foreign_key "daily_menu_items", "daily_menus"
  add_foreign_key "daily_menu_items", "menu_items"
  add_foreign_key "order_items", "menu_items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "users", column: "customer_id"
  add_foreign_key "work_logs", "users", column: "employee_id"
end
