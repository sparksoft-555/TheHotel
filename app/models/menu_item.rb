class MenuItem < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
  validates :estimated_prep_time, numericality: { greater_than: 0 }, allow_blank: true

  # Associations
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :daily_menu_items, dependent: :destroy
  has_many :daily_menus, through: :daily_menu_items

  # Scopes
  scope :available, -> { where(available: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :quick_prep, -> { where('estimated_prep_time <= ?', 15) }
  scope :popular, -> { joins(:order_items).group('menu_items.id').order('COUNT(order_items.id) DESC') }

  # Categories for menu items
  CATEGORIES = %w[appetizer main_course dessert beverage snack].freeze

  validates :category, inclusion: { in: CATEGORIES }

  def formatted_price
    "$#{price.to_f.round(2)}"
  end

  def toggle_availability!
    update!(available: !available)
  end

  def prep_time_display
    estimated_prep_time ? "#{estimated_prep_time} mins" : "Not specified"
  end

  def ingredients_list
    ingredients&.split(',')&.map(&:strip) || []
  end

  def can_be_prepared?
    return true if ingredients.blank?
    
    required_ingredients = ingredients_list
    available_ingredients = InventoryItem.where('quantity > minimum_quantity').pluck(:name)
    
    (required_ingredients - available_ingredients).empty?
  end

  def popularity_score
    order_items.joins(:order)
              .where(orders: { status: 'delivered', created_at: 1.month.ago..Time.current })
              .sum(:quantity)
  end
end
