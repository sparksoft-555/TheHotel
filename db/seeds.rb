# Hotel Management System - Seed Data

begin
  puts "🏨 Seeding Hotel Management System data..."

  # Create users with different roles
  puts "👥 Creating users..."

  # Manager
  manager = User.create!(
    name: "John Manager",
    email: "manager@hotel.com",
    password: "password123",
    role: "manager",
    phone: "555-0101"
  )

  # Chef
  chef = User.create!(
    name: "Maria Chef",
    email: "chef@hotel.com",
    password: "password123",
    role: "chef",
    phone: "555-0102"
  )

  # Cashier
  cashier = User.create!(
    name: "David Cashier",
    email: "cashier@hotel.com",
    password: "password123",
    role: "cashier",
    phone: "555-0103"
  )

  # Accountant
  accountant = User.create!(
    name: "Sarah Accountant",
    email: "accountant@hotel.com",
    password: "password123",
    role: "accountant",
    phone: "555-0104"
  )

  # Sample customers
  customer1 = User.create!(
    name: "Alice Customer",
    email: "alice@example.com",
    password: "password123",
    role: "customer",
    phone: "555-0201"
  )

  customer2 = User.create!(
    name: "Bob Customer",
    email: "bob@example.com",
    password: "password123",
    role: "customer",
    phone: "555-0202"
  )

  puts "✓ Created #{User.count} users"

  # Create menu items
  puts "🍽️ Creating menu items..."

  # Appetizers
  appetizers = [
    { name: "Garlic Bread", description: "Crispy bread with garlic butter and herbs", price: 8.99, category: "appetizer", prep_time_minutes: 10 },
    { name: "Caesar Salad", description: "Fresh romaine lettuce with caesar dressing and croutons", price: 12.99, category: "appetizer", prep_time_minutes: 15 },
    { name: "Chicken Wings", description: "Spicy buffalo wings with blue cheese dip", price: 14.99, category: "appetizer", prep_time_minutes: 20 },
    { name: "Mozzarella Sticks", description: "Crispy breaded mozzarella with marinara sauce", price: 10.99, category: "appetizer", prep_time_minutes: 12 }
  ]

  # Main courses
  main_courses = [
    { name: "Grilled Salmon", description: "Fresh Atlantic salmon with lemon and herbs", price: 24.99, category: "main_course", prep_time_minutes: 25 },
    { name: "Beef Ribeye Steak", description: "12oz ribeye steak cooked to perfection", price: 32.99, category: "main_course", prep_time_minutes: 30 },
    { name: "Chicken Parmesan", description: "Breaded chicken breast with marinara and mozzarella", price: 19.99, category: "main_course", prep_time_minutes: 25 },
    { name: "Vegetarian Pasta", description: "Penne pasta with seasonal vegetables and olive oil", price: 16.99, category: "main_course", prep_time_minutes: 20 },
    { name: "Fish and Chips", description: "Beer-battered cod with crispy fries", price: 18.99, category: "main_course", prep_time_minutes: 22 }
  ]

  # Desserts
  desserts = [
    { name: "Chocolate Cake", description: "Rich chocolate layer cake with vanilla ice cream", price: 8.99, category: "dessert", prep_time_minutes: 5 },
    { name: "Tiramisu", description: "Classic Italian dessert with coffee and mascarpone", price: 9.99, category: "dessert", prep_time_minutes: 5 },
    { name: "Cheesecake", description: "New York style cheesecake with berry compote", price: 8.99, category: "dessert", prep_time_minutes: 5 }
  ]

  # Beverages
  beverages = [
    { name: "Coffee", description: "Freshly brewed house blend", price: 3.99, category: "beverage", prep_time_minutes: 3 },
    { name: "Fresh Orange Juice", description: "Freshly squeezed orange juice", price: 4.99, category: "beverage", prep_time_minutes: 2 },
    { name: "Iced Tea", description: "Sweet or unsweetened iced tea", price: 2.99, category: "beverage", prep_time_minutes: 2 },
    { name: "Soda", description: "Coke, Pepsi, Sprite, or other soft drinks", price: 2.99, category: "beverage", prep_time_minutes: 1 }
  ]

  all_menu_items = appetizers + main_courses + desserts + beverages

  all_menu_items.each do |item_data|
    MenuItem.create!(item_data)
  end

  puts "✓ Created #{MenuItem.count} menu items"

  # Create daily menu for today
  puts "📅 Creating today's menu..."
  today_menu = DailyMenu.create!(
    menu_date: Date.current,
    special_notes: "Welcome to our daily specials!"
  )

  # Add all menu items to today's menu
  MenuItem.all.each_with_index do |item, index|
    DailyMenuItem.create!(
      daily_menu: today_menu,
      menu_item: item,
      featured: index < 3, # First 3 items are featured
      display_order: index + 1
    )
  end

  puts "✓ Created daily menu with #{today_menu.menu_items.count} items"

  # Create inventory items
  puts "📦 Creating inventory items..."

  inventory_data = [
    { name: "Chicken Breast", quantity: 25, unit: "kg", category: "meat", minimum_quantity: 5, cost_per_unit: 8.50, expiry_date: 5.days.from_now },
    { name: "Salmon Fillet", quantity: 15, unit: "kg", category: "meat", minimum_quantity: 3, cost_per_unit: 12.00, expiry_date: 3.days.from_now },
    { name: "Ground Beef", quantity: 20, unit: "kg", category: "meat", minimum_quantity: 5, cost_per_unit: 7.50, expiry_date: 4.days.from_now },
    { name: "Fresh Lettuce", quantity: 12, unit: "pieces", category: "vegetables", minimum_quantity: 3, cost_per_unit: 2.50, expiry_date: 7.days.from_now },
    { name: "Tomatoes", quantity: 8, unit: "kg", category: "vegetables", minimum_quantity: 2, cost_per_unit: 3.00, expiry_date: 6.days.from_now },
    { name: "Mozzarella Cheese", quantity: 5, unit: "kg", category: "dairy", minimum_quantity: 1, cost_per_unit: 6.00, expiry_date: 10.days.from_now },
    { name: "Pasta", quantity: 30, unit: "kg", category: "grains", minimum_quantity: 5, cost_per_unit: 2.00, expiry_date: 365.days.from_now },
    { name: "Coffee Beans", quantity: 10, unit: "kg", category: "beverages", minimum_quantity: 2, cost_per_unit: 15.00, expiry_date: 90.days.from_now }
  ]

  inventory_data.each do |item_data|
    InventoryItem.create!(item_data)
  end

  puts "✓ Created #{InventoryItem.count} inventory items"

  # Create sample orders
  puts "📋 Creating sample orders..."

  # Order 1 - completed order
  order1 = Order.create!(
    customer: customer1,
    table_number: "T-001",
    status: "delivered",
    special_instructions: "No onions please"
  )

  OrderItem.create!(
    order: order1,
    menu_item: MenuItem.find_by(name: "Caesar Salad"),
    quantity: 1,
    price_at_time: 12.99
  )

  OrderItem.create!(
    order: order1,
    menu_item: MenuItem.find_by(name: "Grilled Salmon"),
    quantity: 1,
    price_at_time: 24.99
  )

  # Create bill for order1
  Bill.create!(
    order: order1,
    total_amount: order1.total_amount,
    payment_status: "paid",
    payment_method: "credit_card",
    paid_at: 2.hours.ago
  )

  # Order 2 - active order
  order2 = Order.create!(
    customer: customer2,
    table_number: "T-003",
    status: "preparing",
    special_instructions: "Medium rare steak"
  )

  OrderItem.create!(
    order: order2,
    menu_item: MenuItem.find_by(name: "Beef Ribeye Steak"),
    quantity: 1,
    price_at_time: 32.99
  )

  OrderItem.create!(
    order: order2,
    menu_item: MenuItem.find_by(name: "Coffee"),
    quantity: 2,
    price_at_time: 3.99
  )

  # Create pending bill for order2
  Bill.create!(
    order: order2,
    total_amount: order2.total_amount,
    payment_status: "pending"
  )

  # Order 3 - ready for delivery
  order3 = Order.create!(
    table_number: "T-005",
    status: "ready"
  )

  OrderItem.create!(
    order: order3,
    menu_item: MenuItem.find_by(name: "Chicken Parmesan"),
    quantity: 2,
    price_at_time: 19.99
  )

  Bill.create!(
    order: order3,
    total_amount: order3.total_amount,
    payment_status: "pending"
  )

  puts "✓ Created #{Order.count} orders with #{OrderItem.count} items"
  puts "✓ Created #{Bill.count} bills"

  # Create work logs
  puts "⏰ Creating work logs..."

  # Chef's work log for today
  WorkLog.create!(
    employee: chef,
    clock_in: 8.hours.ago,
    clock_out: 1.hour.ago,
    approved: true,
    notes: "Kitchen prep and lunch service"
  )

  # Cashier's ongoing work
  WorkLog.create!(
    employee: cashier,
    clock_in: 6.hours.ago,
    approved: false,
    notes: "Front desk service"
  )

  puts "✓ Created #{WorkLog.count} work logs"

  puts "\n🎉 Hotel Management System seeding completed successfully!"
  puts "\n📊 Summary:"
  puts "   👥 Users: #{User.count} (#{User.employees.count} employees, #{User.customers.count} customers)"
  puts "   🍽️ Menu Items: #{MenuItem.count}"
  puts "   📅 Daily Menus: #{DailyMenu.count}"
  puts "   📋 Orders: #{Order.count} (#{Order.active.count} active)"
  puts "   💰 Bills: #{Bill.count} (#{Bill.pending.count} pending, #{Bill.paid.count} paid)"
  puts "   📦 Inventory Items: #{InventoryItem.count}"
  puts "   ⏰ Work Logs: #{WorkLog.count}"
  puts "\n🔑 Login credentials:"
  puts "   Manager: manager@hotel.com / password123"
  puts "   Chef: chef@hotel.com / password123"
  puts "   Cashier: cashier@hotel.com / password123"
  puts "   Accountant: accountant@hotel.com / password123"

rescue => e
  puts "❌ Error during seeding: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
