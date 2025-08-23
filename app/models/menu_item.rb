class MenuItem < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true

  # Associations
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :daily_menu_items, dependent: :destroy
  has_many :daily_menus, through: :daily_menu_items

  # Scopes
  scope :available, -> { where(available: true) }
  scope :by_category, ->(category) { where(category: category) }

  # Categories for menu items
  CATEGORIES = %w[appetizer main_course dessert beverage].freeze

  validates :category, inclusion: { in: CATEGORIES }

  def formatted_price
    "$#{price.to_f.round(2)}"
  end

  def toggle_availability!
    update!(available: !available)
  end
end
