class OrdersController < ApplicationController
  def index
    @active_orders = Order.active.includes(:order_items, :menu_items, :customer).order(:created_at)
    @kitchen_orders = Order.for_kitchen.includes(:order_items, :menu_items)
    @ready_orders = Order.ready_for_delivery.includes(:order_items, :menu_items)
  end

  def show
    @order = Order.find(params[:id])
    @order_items = @order.order_items.includes(:menu_item)
  end

  def new
    @order = Order.new
    @daily_menu = DailyMenu.for_today
    @menu_items_by_category = @daily_menu.items_by_category
  end

  def create
    @order = Order.new(order_params)
    
    if @order.save
      # Create order items
      params[:order_items]&.each do |item_data|
        next if item_data[:quantity].to_i <= 0
        
        @order.order_items.create!(
          menu_item_id: item_data[:menu_item_id],
          quantity: item_data[:quantity],
          price_at_time: MenuItem.find(item_data[:menu_item_id]).price
        )
      end
      
      # Create bill
      Bill.create!(
        order: @order,
        total_amount: @order.total_amount
      )
      
      redirect_to orders_path, notice: 'Order created successfully!'
    else
      @daily_menu = DailyMenu.for_today
      @menu_items_by_category = @daily_menu.items_by_category
      render :new
    end
  end

  def update_status
    @order = Order.find(params[:id])
    new_status = params[:status]
    
    if Order::STATUSES.include?(new_status)
      @order.update!(status: new_status)
      redirect_to orders_path, notice: \"Order status updated to #{new_status.humanize}!\"
    else
      redirect_to orders_path, alert: 'Invalid status!'
    end
  end

  def kitchen
    @orders = Order.for_kitchen.includes(:order_items, :menu_items, :customer).order(:created_at)
  end

  def advance_status
    @order = Order.find(params[:id])
    @order.advance_status!
    redirect_back(fallback_location: orders_path, notice: \"Order #{@order.id} status advanced to #{@order.status.humanize}!\")
  end

  private

  def order_params
    params.require(:order).permit(:table_number, :special_instructions, :customer_id)
  end
end