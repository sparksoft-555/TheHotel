class KitchenController < ApplicationController
  before_action :ensure_chef_access

  def dashboard
    @received_orders = Order.where(status: 'received').includes(:order_items, :menu_items, :customer).order(:created_at)
    @preparing_orders = Order.where(status: 'preparing').includes(:order_items, :menu_items, :customer).order(:created_at)
    @ready_orders = Order.where(status: 'ready').includes(:order_items, :menu_items, :customer).order(:created_at)
    @order_stats = calculate_kitchen_stats
  end

  def orders
    authorize Order, :kitchen?
    @orders = policy_scope(Order).for_kitchen.includes(:order_items, :menu_items, :customer).order(:created_at)
  end

  def update_order_status
    @order = Order.find(params[:id])
    authorize @order, :update_status?
    
    new_status = params[:status]
    if Order::STATUSES.include?(new_status) && valid_status_transition?(@order.status, new_status)
      @order.update!(status: new_status)
      
      # Add timestamp tracking
      case new_status
      when 'preparing'
        @order.update!(started_cooking_at: Time.current)
      when 'ready'
        @order.update!(ready_at: Time.current)
      end
      
      respond_to do |format|
        format.json { render json: { status: 'success', message: "Order #{@order.id} updated to #{new_status}" } }
        format.html { redirect_to kitchen_dashboard_path, notice: "Order #{@order.id} status updated!" }
      end
    else
      respond_to do |format|
        format.json { render json: { status: 'error', message: 'Invalid status transition' } }
        format.html { redirect_to kitchen_dashboard_path, alert: 'Invalid status transition!' }
      end
    end
  end

  def order_details
    @order = Order.find(params[:id])
    authorize @order, :show?
    @order_items = @order.order_items.includes(:menu_item)
    
    respond_to do |format|
      format.json { render json: order_details_json(@order) }
      format.html
    end
  end

  def prep_times
    # Show average preparation times for different menu items
    @prep_times = calculate_prep_times
  end

  private

  def ensure_chef_access
    unless current_user&.chef? || current_user&.admin?
      flash[:alert] = "Access denied. Kitchen access required."
      redirect_to root_path
    end
  end

  def calculate_kitchen_stats
    today = Date.current.all_day
    
    {
      orders_today: Order.where(created_at: today).count,
      completed_today: Order.where(created_at: today, status: 'delivered').count,
      average_prep_time: calculate_average_prep_time,
      pending_orders: Order.where(status: ['received', 'preparing']).count
    }
  end

  def calculate_average_prep_time
    completed_orders = Order.where.not(started_cooking_at: nil, ready_at: nil)
                           .where(created_at: 1.week.ago..Time.current)
    
    return 0 if completed_orders.empty?
    
    total_time = completed_orders.sum do |order|
      (order.ready_at - order.started_cooking_at) / 60 # in minutes
    end
    
    (total_time / completed_orders.count).round(1)
  end

  def valid_status_transition?(current_status, new_status)
    valid_transitions = {
      'received' => ['preparing', 'cancelled'],
      'preparing' => ['ready', 'cancelled'],
      'ready' => ['delivered'],
      'delivered' => [],
      'cancelled' => []
    }
    
    valid_transitions[current_status]&.include?(new_status)
  end

  def order_details_json(order)
    {
      id: order.id,
      table_number: order.table_number,
      status: order.status,
      created_at: order.created_at.strftime('%I:%M %p'),
      special_instructions: order.special_instructions,
      items: order.order_items.map do |item|
        {
          name: item.menu_item.name,
          quantity: item.quantity,
          special_requests: item.special_requests
        }
      end,
      customer: order.customer&.name || 'Walk-in',
      total_amount: order.total_amount
    }
  end

  def calculate_prep_times
    MenuItem.joins(order_items: { order: :bills })
           .where(orders: { status: 'delivered' })
           .where.not(orders: { started_cooking_at: nil, ready_at: nil })
           .group('menu_items.name')
           .average('EXTRACT(EPOCH FROM (orders.ready_at - orders.started_cooking_at)) / 60')
           .transform_values { |avg_time| avg_time.round(1) }
           .sort_by { |_, time| -time }
  end
end