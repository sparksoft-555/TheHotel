class DailyMenu < ApplicationRecord
  validates :menu_date, presence: true, uniqueness: true
  
  has_many :daily_menu_items, dependent: :destroy
  has_many :menu_items, through: :daily_menu_items
  
  scope :current, -> { where(menu_date: Date.current) }
  scope :upcoming, -> { where('menu_date > ?', Date.current) }
  scope :past, -> { where('menu_date < ?', Date.current) }
  
  def self.for_today
    find_or_create_by(menu_date: Date.current)
  end
  
  def items_by_category
    menu_items.available.group_by(&:category)
  end
  
  def total_items
    menu_items.count
  end
  
  def available_items
    menu_items.available.count
  end
  
  def is_today?
    menu_date == Date.current
  end
  
  def is_future?
    menu_date > Date.current
  end
  
  def formatted_date
    menu_date.strftime('%B %d, %Y')
  end
end