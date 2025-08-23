class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    # Add any data you want to display on the admin dashboard
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: 'You are not authorized to perform this action.' unless current_user.admin?
  end
end
