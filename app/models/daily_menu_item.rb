class DailyMenuItem < ApplicationRecord
  belongs_to :daily_menu
  belongs_to :menu_item

  validates :daily_menu_id, uniqueness: { scope: :menu_item_id }
end
