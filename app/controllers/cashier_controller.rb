class CashierController < ApplicationController
  before_action :ensure_cashier_access

  def dashboard
    @ready_orders = Order.ready_for_delivery.includes(:order_items, :menu_items, :customer, :bill)
    @daily_stats = calculate_daily_stats
    @payment_methods = calculate_payment_methods
    @recent_transactions = get_recent_transactions
  end

  def billing
    @orders_for_billing = Order.where(status: 'ready').includes(:order_items, :menu_items, :bill)
  end

  def generate_bill
    @order = Order.find(params[:id])
    authorize @order, :show?
    
    # Create or update bill
    @bill = @order.bill || @order.build_bill
    @bill.update!(
      total_amount: @order.total_amount,
      tax_amount: calculate_tax(@order.total_amount),
      service_charge: calculate_service_charge(@order.total_amount),
      final_amount: calculate_final_amount(@order.total_amount)
    )
    
    respond_to do |format|
      format.html
      format.pdf { render_bill_pdf(@bill) }
      format.json { render json: bill_json(@bill) }
    end
  end

  def process_payment
    @order = Order.find(params[:id])
    @bill = @order.bill
    authorize @order, :show?
    
    payment_method = params[:payment_method]
    amount_received = params[:amount_received].to_f
    
    if amount_received >= @bill.final_amount
      @bill.update!(
        payment_method: payment_method,
        amount_received: amount_received,
        change_amount: amount_received - @bill.final_amount,
        paid_at: Time.current,
        status: 'paid'
      )
      
      @order.update!(status: 'delivered')
      
      flash[:notice] = "Payment processed successfully!"
      redirect_to cashier_dashboard_path
    else
      flash[:alert] = "Insufficient payment amount!"
      redirect_to generate_bill_path(@order)
    end
  end

  def daily_report
    @date = params[:date]&.to_date || Date.current
    @daily_bills = Bill.joins(:order)
                      .where(orders: { created_at: @date.all_day }, status: 'paid')
                      .includes(:order)
    
    @total_revenue = @daily_bills.sum(:final_amount)
    @total_tax = @daily_bills.sum(:tax_amount)
    @total_service_charge = @daily_bills.sum(:service_charge)
    @payment_breakdown = @daily_bills.group(:payment_method).sum(:final_amount)
    @orders_count = @daily_bills.count
  end

  def transaction_history
    @page = params[:page] || 1
    @transactions = Bill.joins(:order)
                       .where(status: 'paid')
                       .includes(:order)
                       .order(paid_at: :desc)
                       .limit(50)
                       .offset((@page.to_i - 1) * 50)
  end

  private

  def ensure_cashier_access
    unless current_user&.can_handle_payments?
      flash[:alert] = "Access denied. Cashier privileges required."
      redirect_to root_path
    end
  end

  def calculate_daily_stats
    today = Date.current.all_day
    today_bills = Bill.joins(:order).where(orders: { created_at: today }, status: 'paid')
    
    {
      total_revenue: today_bills.sum(:final_amount),
      total_orders: today_bills.count,
      average_order_value: today_bills.average(:final_amount)&.round(2) || 0,
      total_tax_collected: today_bills.sum(:tax_amount),
      total_service_charge: today_bills.sum(:service_charge)
    }
  end

  def calculate_payment_methods
    today = Date.current.all_day
    Bill.joins(:order)
       .where(orders: { created_at: today }, status: 'paid')
       .group(:payment_method)
       .sum(:final_amount)
  end

  def get_recent_transactions
    Bill.joins(:order)
       .where(status: 'paid')
       .includes(:order)
       .order(paid_at: :desc)
       .limit(10)
  end

  def calculate_tax(amount)
    # Assuming 10% tax rate - this should be configurable
    (amount * 0.10).round(2)
  end

  def calculate_service_charge(amount)
    # Assuming 5% service charge - this should be configurable
    (amount * 0.05).round(2)
  end

  def calculate_final_amount(base_amount)
    base_amount + calculate_tax(base_amount) + calculate_service_charge(base_amount)
  end

  def render_bill_pdf(bill)
    # PDF generation logic would go here
    # For now, we'll just redirect to HTML version
    redirect_to generate_bill_path(bill.order, format: :html)
  end

  def bill_json(bill)
    {
      id: bill.id,
      order_id: bill.order.id,
      table_number: bill.order.table_number,
      items: bill.order.order_items.map do |item|
        {
          name: item.menu_item.name,
          quantity: item.quantity,
          price: item.price_at_time,
          total: item.quantity * item.price_at_time
        }
      end,
      subtotal: bill.total_amount,
      tax: bill.tax_amount,
      service_charge: bill.service_charge,
      final_total: bill.final_amount,
      created_at: bill.created_at.strftime('%Y-%m-%d %I:%M %p')
    }
  end
end