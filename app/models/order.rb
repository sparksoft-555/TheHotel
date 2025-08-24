class Order < ApplicationRecord
  # Associations
  belongs_to :customer, class_name: "User", optional: true
  has_many :order_items, dependent: :destroy
  has_many :menu_items, through: :order_items
  has_one :bill, dependent: :destroy

  validates :table_number, presence: true
  validates :status, inclusion: { in: %w[received preparing ready delivered cancelled] }

  # Order statuses
  STATUSES = %w[received preparing ready delivered cancelled].freeze

  # Scopes
  scope :active, -> { where.not(status: [ "delivered", "cancelled" ]) }
  scope :for_kitchen, -> { where(status: [ "received", "preparing" ]) }
  scope :ready_for_delivery, -> { where(status: "ready") }
  scope :todays_orders, -> { where(created_at: Date.current.all_day) }

  def total_amount
    order_items.sum { |item| item.quantity * item.price_at_time }
  end

  def can_be_cancelled?
    status == "received"
  end

  def next_status
    case status
    when "received" then "preparing"
    when "preparing" then "ready"
    when "ready" then "delivered"
    else status
    end
  end

  def advance_status!
    update!(status: next_status) unless status == "delivered"
  end

  def formatted_total
    "$#{total_amount.to_f.round(2)}"
  end

  def preparation_time
    return nil unless started_cooking_at && ready_at
    ((ready_at - started_cooking_at) / 60).round(1) # in minutes
  end

  def total_time
    return nil unless ready_at
    ((ready_at - created_at) / 60).round(1) # in minutes
  end

  def estimated_ready_time
    return nil unless started_cooking_at
    # Estimate based on menu items - this could be more sophisticated
    estimated_minutes = order_items.sum { |item| item.menu_item.estimated_prep_time || 15 }
    started_cooking_at + estimated_minutes.minutes
  end
end
