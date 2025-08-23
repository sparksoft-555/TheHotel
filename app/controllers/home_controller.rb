class HomeController < ApplicationController
  def index
    @hotels = [
      { name: "Grand Hotel", rooms: 50, available: 23 },
      { name: "City Inn", rooms: 30, available: 12 },
      { name: "Ocean View", rooms: 75, available: 45 }
    ]
  end

  def dashboard
    @total_rooms = 155
    @available_rooms = 80
    @occupied_rooms = 75
    @revenue_today = 2500.50
  end
end
