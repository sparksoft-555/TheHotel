class HomeController < ApplicationController
  def index
    # Redirect users to their role-specific dashboard
    if user_signed_in?
      redirect_to role_dashboard_path
    else
      # Show login/welcome page for non-authenticated users
      @featured_menu_items = MenuItem.available.limit(6)
    end
  end

  def dashboard
    # Legacy dashboard - redirect to role-specific dashboard
    redirect_to role_dashboard_path
  end

  private

  def role_dashboard_path
    case current_user.role
    when 'admin'
      admin_dashboard_path
    when 'manager'
      manager_dashboard_path
    when 'chef'
      kitchen_dashboard_path
    when 'cashier'
      cashier_dashboard_path
    when 'accountant'
      accountant_dashboard_path
    when 'customer'
      orders_path # Customers can see their orders
    else
      orders_path # Default fallback
    end
  end
end
