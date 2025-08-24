class AccountantController < ApplicationController
  before_action :ensure_accountant_access

  def dashboard
    @financial_overview = calculate_financial_overview
    @monthly_trends = calculate_monthly_trends
    @expense_breakdown = calculate_expense_breakdown
    @profit_loss = calculate_profit_loss
  end

  def revenue_reports
    @period = params[:period] || 'month'
    @start_date = params[:start_date]&.to_date || 1.month.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.current
    
    @revenue_data = generate_revenue_report(@start_date, @end_date)
    @daily_breakdown = generate_daily_breakdown(@start_date, @end_date)
    @category_breakdown = generate_category_breakdown(@start_date, @end_date)
  end

  def expense_reports
    @period = params[:period] || 'month'
    @start_date = params[:start_date]&.to_date || 1.month.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.current
    
    @expense_data = generate_expense_report(@start_date, @end_date)
    @inventory_costs = calculate_inventory_costs(@start_date, @end_date)
    @staff_costs = calculate_staff_costs(@start_date, @end_date)
  end

  def profit_loss_statement
    @period = params[:period] || 'month'
    @start_date = params[:start_date]&.to_date || 1.month.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.current
    
    @revenue = calculate_total_revenue(@start_date, @end_date)
    @expenses = calculate_total_expenses(@start_date, @end_date)
    @gross_profit = @revenue - @expenses[:cost_of_goods_sold]
    @net_profit = @gross_profit - @expenses[:operating_expenses]
    
    @profit_margin = @revenue > 0 ? ((@net_profit / @revenue) * 100).round(2) : 0
  end

  def tax_reports
    @period = params[:period] || 'month'
    @start_date = params[:start_date]&.to_date || 1.month.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.current
    
    @tax_collected = calculate_tax_collected(@start_date, @end_date)
    @tax_breakdown = generate_tax_breakdown(@start_date, @end_date)
    @service_charges = calculate_service_charges(@start_date, @end_date)
  end

  def inventory_valuation
    @current_inventory = InventoryItem.all
    @total_inventory_value = @current_inventory.sum { |item| item.quantity * item.unit_price }
    @low_stock_value = @current_inventory.where('quantity < minimum_quantity')
                                        .sum { |item| item.quantity * item.unit_price }
    @expiring_value = @current_inventory.where('expiry_date <= ?', 1.week.from_now)
                                       .sum { |item| item.quantity * item.unit_price }
  end

  def export_data
    @format = params[:format] || 'csv'
    @report_type = params[:report_type] || 'revenue'
    @start_date = params[:start_date]&.to_date || 1.month.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.current
    
    case @report_type
    when 'revenue'
      data = generate_revenue_export(@start_date, @end_date)
    when 'expenses'
      data = generate_expense_export(@start_date, @end_date)
    when 'profit_loss'
      data = generate_profit_loss_export(@start_date, @end_date)
    else
      data = []
    end
    
    respond_to do |format|
      format.csv { send_data data.to_csv, filename: "#{@report_type}_#{@start_date}_#{@end_date}.csv" }
      format.json { render json: data }
    end
  end

  private

  def ensure_accountant_access
    unless current_user&.can_view_financial_reports?
      flash[:alert] = "Access denied. Accountant privileges required."
      redirect_to root_path
    end
  end

  def calculate_financial_overview
    current_month = Date.current.beginning_of_month..Date.current.end_of_month
    previous_month = 1.month.ago.beginning_of_month..1.month.ago.end_of_month
    
    current_revenue = calculate_total_revenue(current_month.first, current_month.last)
    previous_revenue = calculate_total_revenue(previous_month.first, previous_month.last)
    
    {
      current_month_revenue: current_revenue,
      previous_month_revenue: previous_revenue,
      revenue_growth: previous_revenue > 0 ? (((current_revenue - previous_revenue) / previous_revenue) * 100).round(2) : 0,
      total_orders_this_month: Order.where(created_at: current_month, status: 'delivered').count,
      average_order_value: current_revenue > 0 ? (current_revenue / Order.where(created_at: current_month, status: 'delivered').count).round(2) : 0
    }
  end

  def calculate_monthly_trends
    (11.months.ago.to_date..Date.current).group_by { |date| date.beginning_of_month }.map do |month_start, _|
      month_end = month_start.end_of_month
      revenue = calculate_total_revenue(month_start, month_end)
      
      {
        month: month_start.strftime('%b %Y'),
        revenue: revenue,
        orders: Order.where(created_at: month_start..month_end, status: 'delivered').count
      }
    end
  end

  def calculate_expense_breakdown
    # This would typically come from an expenses table
    # For now, we'll calculate based on inventory and estimated operational costs
    current_month = Date.current.beginning_of_month..Date.current.end_of_month
    
    {
      inventory_costs: calculate_inventory_costs(current_month.first, current_month.last),
      staff_costs: calculate_staff_costs(current_month.first, current_month.last),
      utilities: 2000, # Estimated - should come from actual data
      rent: 5000,      # Estimated - should come from actual data
      marketing: 500   # Estimated - should come from actual data
    }
  end

  def calculate_profit_loss
    current_month = Date.current.beginning_of_month..Date.current.end_of_month
    
    revenue = calculate_total_revenue(current_month.first, current_month.last)
    expenses = calculate_total_expenses(current_month.first, current_month.last)
    
    {
      revenue: revenue,
      total_expenses: expenses[:total],
      gross_profit: revenue - expenses[:cost_of_goods_sold],
      net_profit: revenue - expenses[:total]
    }
  end

  def generate_revenue_report(start_date, end_date)
    Bill.joins(:order)
       .where(orders: { created_at: start_date..end_date }, status: 'paid')
       .group_by_day(:paid_at)
       .sum(:final_amount)
  end

  def generate_daily_breakdown(start_date, end_date)
    Bill.joins(:order)
       .where(orders: { created_at: start_date..end_date }, status: 'paid')
       .includes(:order)
       .group_by { |bill| bill.paid_at.to_date }
       .transform_values do |bills|
         {
           total_revenue: bills.sum(&:final_amount),
           total_orders: bills.count,
           average_order_value: bills.sum(&:final_amount) / bills.count.to_f
         }
       end
  end

  def generate_category_breakdown(start_date, end_date)
    MenuItem.joins(order_items: { order: :bill })
           .where(orders: { created_at: start_date..end_date, status: 'delivered' })
           .where(bills: { status: 'paid' })
           .group('menu_items.category')
           .sum('order_items.quantity * order_items.price_at_time')
  end

  def calculate_total_revenue(start_date, end_date)
    Bill.joins(:order)
       .where(orders: { created_at: start_date..end_date }, status: 'paid')
       .sum(:final_amount)
  end

  def calculate_total_expenses(start_date, end_date)
    inventory_costs = calculate_inventory_costs(start_date, end_date)
    staff_costs = calculate_staff_costs(start_date, end_date)
    
    # These should come from an actual expenses table in a real application
    operating_expenses = 7500 # Estimated monthly operational costs
    
    {
      cost_of_goods_sold: inventory_costs,
      staff_costs: staff_costs,
      operating_expenses: operating_expenses,
      total: inventory_costs + staff_costs + operating_expenses
    }
  end

  def calculate_inventory_costs(start_date, end_date)
    # This is a simplified calculation
    # In a real system, you'd track actual inventory usage and costs
    orders_count = Order.where(created_at: start_date..end_date, status: 'delivered').count
    estimated_cost_per_order = 8.50 # This should be calculated based on actual ingredients costs
    
    orders_count * estimated_cost_per_order
  end

  def calculate_staff_costs(start_date, end_date)
    # Calculate based on work logs and hourly rates
    total_hours = WorkLog.joins(:user)
                        .where(date: start_date..end_date)
                        .sum(:hours_worked)
    
    average_hourly_rate = 15.0 # This should come from user records
    total_hours * average_hourly_rate
  end

  def calculate_tax_collected(start_date, end_date)
    Bill.joins(:order)
       .where(orders: { created_at: start_date..end_date }, status: 'paid')
       .sum(:tax_amount)
  end

  def calculate_service_charges(start_date, end_date)
    Bill.joins(:order)
       .where(orders: { created_at: start_date..end_date }, status: 'paid')
       .sum(:service_charge)
  end

  def generate_tax_breakdown(start_date, end_date)
    Bill.joins(:order)
       .where(orders: { created_at: start_date..end_date }, status: 'paid')
       .group_by_day(:paid_at)
       .sum(:tax_amount)
  end
end