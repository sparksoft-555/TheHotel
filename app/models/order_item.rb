class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :menu_item

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_at_time, presence: true, numericality: { greater_than: 0 }

  # Set price at time of order creation
  before_validation :set_price_at_time, on: :create

  def total_price
    quantity * price_at_time
  end

  def formatted_total
    "$#{total_price.to_f.round(2)}"
  end

  private

  def set_price_at_time
    self.price_at_time = menu_item.price if menu_item && price_at_time.blank?
  end
end
