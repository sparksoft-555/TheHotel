class InventoryItem < ApplicationRecord
  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, presence: true
  validates :category, presence: true

  # Categories for inventory items
  CATEGORIES = %w[vegetables meat dairy grains beverages cleaning supplies].freeze
  UNITS = %w[kg lbs pieces liters gallons bottles boxes].freeze

  validates :category, inclusion: { in: CATEGORIES }
  validates :unit, inclusion: { in: UNITS }

  # Scopes
  scope :low_stock, -> { where("quantity < minimum_quantity") }
  scope :expiring_soon, -> { where("expiry_date <= ?", 3.days.from_now) }
  scope :by_category, ->(category) { where(category: category) }

  def low_stock?
    minimum_quantity && quantity < minimum_quantity
  end

  def expiring_soon?
    expiry_date && expiry_date <= 3.days.from_now
  end

  def expired?
    expiry_date && expiry_date < Date.current
  end

  def status
    return "expired" if expired?
    return "expiring_soon" if expiring_soon?
    return "low_stock" if low_stock?
    "good"
  end

  def update_stock!(change)
    update!(quantity: quantity + change)
  end

  def formatted_quantity
    "#{quantity} #{unit}"
  end
end
