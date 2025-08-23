class MenuController < ApplicationController
  def index
    @daily_menu = DailyMenu.for_today
    @menu_items_by_category = @daily_menu.items_by_category
    @featured_items = @daily_menu.menu_items.joins(:daily_menu_items).where(daily_menu_items: { featured: true })
  end

  def show
    @menu_item = MenuItem.find(params[:id])
  end

  def manage
    @menu_items = MenuItem.all.order(:category, :name)
    @categories = MenuItem::CATEGORIES
  end

  def new
    @menu_item = MenuItem.new
    @categories = MenuItem::CATEGORIES
  end

  def create
    @menu_item = MenuItem.new(menu_item_params)

    if @menu_item.save
      redirect_to manage_menu_index_path, notice: "Menu item created successfully!"
    else
      @categories = MenuItem::CATEGORIES
      render :new
    end
  end

  def edit
    @menu_item = MenuItem.find(params[:id])
    @categories = MenuItem::CATEGORIES
  end

  def update
    @menu_item = MenuItem.find(params[:id])

    if @menu_item.update(menu_item_params)
      redirect_to manage_menu_index_path, notice: "Menu item updated successfully!"
    else
      @categories = MenuItem::CATEGORIES
      render :edit
    end
  end

  def toggle_availability
    @menu_item = MenuItem.find(params[:id])
    @menu_item.toggle_availability!
    redirect_to manage_menu_index_path, notice: "#{@menu_item.name} availability updated!"
  end

  private

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price, :category, :available, :ingredients, :dietary_info, :prep_time_minutes)
  end
end
