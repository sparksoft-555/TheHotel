# Hotel Management System - Seed Data

begin
  puts "🏨 Seeding Hotel Management System data..."

  # Create initial users for testing the hotel management system

  puts "Creating initial users..."

  # Admin user
  admin = User.find_or_create_by(email: 'admin@hotel.com') do |user|
    user.name = 'System Administrator'
    user.role = 'admin'
    user.password = 'password123'
    user.password_confirmation = 'password123'
  end
  puts "✓ Admin user created: #{admin.email}"

  # Manager user
  manager = User.find_or_create_by(email: 'manager@hotel.com') do |user|
    user.name = 'Restaurant Manager'
    user.role = 'manager'
    user.password = 'password123'
    user.password_confirmation = 'password123'
  end
  puts "✓ Manager user created: #{manager.email}"

  # Chef user
  chef = User.find_or_create_by(email: 'chef@hotel.com') do |user|
    user.name = 'Head Chef'
    user.role = 'chef'
    user.password = 'password123'
    user.password_confirmation = 'password123'
  end
  puts "✓ Chef user created: #{chef.email}"

  # Cashier user
  cashier = User.find_or_create_by(email: 'cashier@hotel.com') do |user|
    user.name = 'Front Cashier'
    user.role = 'cashier'
    user.password = 'password123'
    user.password_confirmation = 'password123'
  end
  puts "✓ Cashier user created: #{cashier.email}"

  # Accountant user
  accountant = User.find_or_create_by(email: 'accountant@hotel.com') do |user|
    user.name = 'Finance Officer'
    user.role = 'accountant'
    user.password = 'password123'
    user.password_confirmation = 'password123'
  end
  puts "✓ Accountant user created: #{accountant.email}"

  # Sample customer
  customer = User.find_or_create_by(email: 'customer@example.com') do |user|
    user.name = 'John Customer'
    user.role = 'customer'
    user.password = 'password123'
    user.password_confirmation = 'password123'
  end
  puts "✓ Customer user created: #{customer.email}"

  puts "\n=== Sample Login Credentials ==="
  puts "Admin: admin@hotel.com / password123"
  puts "Manager: manager@hotel.com / password123"
  puts "Chef: chef@hotel.com / password123"
  puts "Cashier: cashier@hotel.com / password123"
  puts "Accountant: accountant@hotel.com / password123"
  puts "Customer: customer@example.com / password123"

  # Create sample menu items if none exist
  if MenuItem.count == 0
    puts "\nCreating sample menu items..."
    
    menu_items = [
      {
        name: 'Grilled Chicken Breast',
        price: 18.99,
        category: 'main_course',
        description: 'Tender grilled chicken with herbs and spices',
        estimated_prep_time: 25,
        ingredients: 'chicken breast, herbs, spices, olive oil',
        available: true
      },
      {
        name: 'Caesar Salad',
        price: 12.99,
        category: 'appetizer',
        description: 'Fresh romaine lettuce with caesar dressing',
        estimated_prep_time: 10,
        ingredients: 'romaine lettuce, caesar dressing, croutons, parmesan',
        available: true
      },
      {
        name: 'Chocolate Brownie',
        price: 8.99,
        category: 'dessert',
        description: 'Rich chocolate brownie with vanilla ice cream',
        estimated_prep_time: 5,
        ingredients: 'brownie, vanilla ice cream, chocolate sauce',
        available: true
      },
      {
        name: 'Fresh Orange Juice',
        price: 4.99,
        category: 'beverage',
        description: 'Freshly squeezed orange juice',
        estimated_prep_time: 3,
        ingredients: 'fresh oranges',
        available: true
      },
      {
        name: 'Fish and Chips',
        price: 16.99,
        category: 'main_course',
        description: 'Crispy battered fish with golden fries',
        estimated_prep_time: 20,
        ingredients: 'white fish, batter, potatoes, oil',
        available: true
      }
    ]
    
    menu_items.each do |item_attrs|
      MenuItem.create!(item_attrs)
      puts "  ✓ Created: #{item_attrs[:name]}"
    end
  end

  # Create sample inventory items if none exist
  if InventoryItem.count == 0
    puts "\nCreating sample inventory items..."
    
    inventory_items = [
      {
        name: 'Chicken Breast',
        quantity: 50,
        unit: 'pieces',
        unit_price: 3.50,
        minimum_quantity: 20,
        expiry_date: 5.days.from_now
      },
      {
        name: 'Romaine Lettuce',
        quantity: 25,
        unit: 'heads',
        unit_price: 1.20,
        minimum_quantity: 10,
        expiry_date: 3.days.from_now
      },
      {
        name: 'Fresh Oranges',
        quantity: 100,
        unit: 'pieces',
        unit_price: 0.50,
        minimum_quantity: 30,
        expiry_date: 7.days.from_now
      },
      {
        name: 'White Fish',
        quantity: 30,
        unit: 'fillets',
        unit_price: 4.00,
        minimum_quantity: 15,
        expiry_date: 2.days.from_now
      },
      {
        name: 'Potatoes',
        quantity: 8,  # This is below minimum to test low stock alerts
        unit: 'kg',
        unit_price: 1.50,
        minimum_quantity: 20,
        expiry_date: 14.days.from_now
      }
    ]
    
    inventory_items.each do |item_attrs|
      InventoryItem.create!(item_attrs)
      puts "  ✓ Created: #{item_attrs[:name]} (#{item_attrs[:quantity]} #{item_attrs[:unit]})"
    end
  end

  puts "\n🎉 Hotel Management System setup complete!"
  puts "You can now test the different role-based dashboards."
  puts "\nNext steps:"
  puts "1. Run the migration: rails db:migrate"
  puts "2. Start the server: rails server"
  puts "3. Visit http://localhost:3000 and login with any of the above credentials"
  puts "4. Each role will redirect to their appropriate dashboard"

rescue => e
  puts "❌ Error during seeding: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
