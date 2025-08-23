class InventoryController < ApplicationController
  def index
    @inventory_items = InventoryItem.all.order(:category, :name)
    @low_stock_items = InventoryItem.low_stock
    @expiring_items = InventoryItem.expiring_soon
    @categories = InventoryItem::CATEGORIES
  end

  def show
    @inventory_item = InventoryItem.find(params[:id])
  end

  def new
    @inventory_item = InventoryItem.new
    @categories = InventoryItem::CATEGORIES
    @units = InventoryItem::UNITS
  end

  def create
    @inventory_item = InventoryItem.new(inventory_item_params)
    
    if @inventory_item.save
      redirect_to inventory_index_path, notice: 'Inventory item created successfully!'
    else
      @categories = InventoryItem::CATEGORIES
      @units = InventoryItem::UNITS
      render :new
    end
  end

  def edit
    @inventory_item = InventoryItem.find(params[:id])
    @categories = InventoryItem::CATEGORIES
    @units = InventoryItem::UNITS
  end

  def update
    @inventory_item = InventoryItem.find(params[:id])
    
    if @inventory_item.update(inventory_item_params)
      redirect_to inventory_index_path, notice: 'Inventory item updated successfully!'
    else
      @categories = InventoryItem::CATEGORIES
      @units = InventoryItem::UNITS
      render :edit
    end
  end

  def update_stock
    @inventory_item = InventoryItem.find(params[:id])
    change = params[:stock_change].to_f
    
    @inventory_item.update_stock!(change)
    redirect_to inventory_index_path, notice: \"Stock updated for #{@inventory_item.name}!\"
  rescue => e
    redirect_to inventory_index_path, alert: \"Error updating stock: #{e.message}\"
  end

  def alerts
    @low_stock_items = InventoryItem.low_stock.order(:name)
    @expiring_items = InventoryItem.expiring_soon.order(:expiry_date)
    @expired_items = InventoryItem.where('expiry_date < ?', Date.current).order(:expiry_date)
  end

  private

  def inventory_item_params
    params.require(:inventory_item).permit(:name, :quantity, :unit, :category, :expiry_date, :minimum_quantity, :cost_per_unit, :supplier, :notes)
  end
end