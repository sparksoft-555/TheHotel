class AdminController < ApplicationController
  before_action :ensure_admin

  def dashboard
    @total_orders_today = Order.where(created_at: Date.current.all_day).count
    @total_revenue_today = Order.joins(:bill)
                               .where(created_at: Date.current.all_day, status: 'delivered')
                               .sum('bills.total_amount')
    @active_orders = Order.active.count
    @low_inventory_items = InventoryItem.where('quantity < minimum_quantity').limit(5)
    @recent_orders = Order.includes(:customer, :order_items, :menu_items)
                          .order(created_at: :desc).limit(10)
  end

  def users
    @users = policy_scope(User).includes(:work_logs, :orders)
    @employees = @users.employees
    @customers = @users.customers
  end

  def analytics
    @daily_revenue = calculate_daily_revenue
    @popular_items = calculate_popular_items
    @peak_hours = calculate_peak_hours
  end

  private

  def ensure_admin
    unless current_user&.admin?
      flash[:alert] = "Access denied. Admin privileges required."
      redirect_to root_path
    end
  end

  def calculate_daily_revenue
    # Revenue for last 7 days
    (6.days.ago.to_date..Date.current).map do |date|
      {
        date: date.strftime('%b %d'),
        revenue: Order.joins(:bill)
                     .where(created_at: date.all_day, status: 'delivered')
                     .sum('bills.total_amount')
      }
    end
  end

  def calculate_popular_items
    MenuItem.joins(order_items: :order)
           .where(orders: { status: 'delivered', created_at: 1.week.ago..Time.current })
           .group('menu_items.name')
           .sum('order_items.quantity')
           .sort_by { |_, quantity| -quantity }
           .first(5)
  end

  def calculate_peak_hours
    Order.where(created_at: 1.week.ago..Time.current)
         .group_by { |order| order.created_at.hour }
         .transform_values(&:count)
         .sort_by { |hour, _| hour }
  end
end