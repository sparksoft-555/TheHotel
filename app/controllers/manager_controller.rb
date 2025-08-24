class ManagerController < ApplicationController
  before_action :ensure_manager_or_admin

  def dashboard
    @inventory_status = get_inventory_status
    @menu_suggestions = generate_ai_menu_suggestions
    @daily_revenue = calculate_daily_revenue
    @popular_items = get_popular_items
    @expiring_items = get_expiring_items
    @weather_info = get_weather_info # For future weather-based suggestions
  end

  def inventory
    authorize InventoryItem
    @inventory_items = policy_scope(InventoryItem).order(:name)
    @low_stock_items = @inventory_items.where('quantity < minimum_quantity')
    @expiring_soon = @inventory_items.where('expiry_date <= ?', 3.days.from_now)
  end

  def menu_management
    authorize MenuItem
    @menu_items = policy_scope(MenuItem).includes(:daily_menu_items)
    @categories = MenuItem.distinct.pluck(:category).compact
    @daily_menu = DailyMenu.for_today
  end

  def reports
    @date_range = params[:date_range] || 'week'
    @revenue_report = generate_revenue_report(@date_range)
    @items_report = generate_items_report(@date_range)
    @orders_report = generate_orders_report(@date_range)
  end

  private

  def ensure_manager_or_admin
    unless current_user&.can_manage_restaurant?
      flash[:alert] = "Access denied. Manager privileges required."
      redirect_to root_path
    end
  end

  def get_inventory_status
    {
      total_items: InventoryItem.count,
      low_stock: InventoryItem.where('quantity < minimum_quantity').count,
      expiring_soon: InventoryItem.where('expiry_date <= ?', 3.days.from_now).count,
      total_value: InventoryItem.sum('quantity * unit_price')
    }
  end

  def generate_ai_menu_suggestions
    # AI-powered menu suggestions based on:
    # - Available inventory
    # - Popular items
    # - Seasonal factors
    # - Expiring ingredients
    
    available_ingredients = InventoryItem.where('quantity > minimum_quantity').pluck(:name)
    expiring_ingredients = InventoryItem.where('expiry_date <= ?', 2.days.from_now).pluck(:name)
    popular_items = get_popular_items.keys
    
    suggestions = []
    
    # Suggest using expiring ingredients first
    expiring_ingredients.each do |ingredient|
      matching_items = MenuItem.where("ingredients LIKE ?", "%#{ingredient}%").limit(2)
      matching_items.each do |item|
        suggestions << {
          item: item.name,
          reason: "Uses expiring ingredient: #{ingredient}",
          priority: 'high',
          type: 'waste_reduction'
        }
      end
    end
    
    # Suggest popular items that we can make
    popular_items.first(3).each do |item_name|
      item = MenuItem.find_by(name: item_name)
      if item && has_sufficient_ingredients?(item)
        suggestions << {
          item: item.name,
          reason: "Popular item with available ingredients",
          priority: 'medium',
          type: 'revenue_boost'
        }
      end
    end
    
    suggestions.uniq { |s| s[:item] }.first(5)
  end

  def has_sufficient_ingredients?(menu_item)
    # Simple check - in a real app, this would be more sophisticated
    return true if menu_item.ingredients.blank?
    
    required_ingredients = menu_item.ingredients.split(',').map(&:strip)
    available_ingredients = InventoryItem.where('quantity > minimum_quantity').pluck(:name)
    
    (required_ingredients - available_ingredients).empty?
  end

  def get_popular_items
    MenuItem.joins(order_items: :order)
           .where(orders: { status: 'delivered', created_at: 1.week.ago..Time.current })
           .group('menu_items.name')
           .sum('order_items.quantity')
           .sort_by { |_, quantity| -quantity }
  end

  def get_expiring_items
    InventoryItem.where('expiry_date <= ?', 3.days.from_now)
                .order(:expiry_date)
                .limit(5)
  end

  def get_weather_info
    # Placeholder for weather API integration
    # In a real app, you'd integrate with a weather service
    {
      condition: 'sunny',
      temperature: 25,
      suggestion: 'Great day for cold beverages and salads!'
    }
  end

  def calculate_daily_revenue
    date_range = case params[:period]
                when 'month' then 30.days.ago..Time.current
                when 'week' then 1.week.ago..Time.current
                else Date.current.all_day
                end

    Order.joins(:bill)
         .where(created_at: date_range, status: 'delivered')
         .sum('bills.total_amount')
  end

  def generate_revenue_report(period)
    case period
    when 'month'
      start_date = 30.days.ago.to_date
      group_by = :day
    when 'week'
      start_date = 1.week.ago.to_date
      group_by = :day
    else
      start_date = Date.current
      group_by = :hour
    end

    Order.joins(:bill)
         .where(created_at: start_date..Time.current, status: 'delivered')
         .group_by_period(group_by, :created_at)
         .sum('bills.total_amount')
  end

  def generate_items_report(period)
    start_date = case period
                when 'month' then 30.days.ago
                when 'week' then 1.week.ago
                else Date.current.beginning_of_day
                end

    MenuItem.joins(order_items: :order)
           .where(orders: { created_at: start_date..Time.current, status: 'delivered' })
           .group('menu_items.name')
           .sum('order_items.quantity')
           .sort_by { |_, quantity| -quantity }
  end

  def generate_orders_report(period)
    start_date = case period
                when 'month' then 30.days.ago
                when 'week' then 1.week.ago
                else Date.current.beginning_of_day
                end

    {
      total_orders: Order.where(created_at: start_date..Time.current).count,
      completed_orders: Order.where(created_at: start_date..Time.current, status: 'delivered').count,
      cancelled_orders: Order.where(created_at: start_date..Time.current, status: 'cancelled').count,
      average_order_value: Order.joins(:bill)
                               .where(created_at: start_date..Time.current, status: 'delivered')
                               .average('bills.total_amount')
    }
  end
end