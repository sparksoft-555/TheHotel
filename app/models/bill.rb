class Bill < ApplicationRecord
  belongs_to :order

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending paid cancelled] }

  STATUSES = %w[pending paid cancelled].freeze
  PAYMENT_METHODS = %w[cash credit_card debit_card mobile_payment upi].freeze

  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, allow_blank: true

  scope :pending, -> { where(status: "pending") }
  scope :paid, -> { where(status: "paid") }
  scope :for_date, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :todays_revenue, -> { paid.where(paid_at: Date.current.all_day) }

  def mark_as_paid!(method = "cash", amount_received = nil)
    update!(
      status: "paid",
      payment_method: method,
      paid_at: Time.current,
      amount_received: amount_received || final_amount,
      change_amount: amount_received ? [amount_received - final_amount, 0].max : 0
    )
  end

  def cancel!
    update!(status: "cancelled")
  end

  def pending?
    status == "pending"
  end

  def paid?
    status == "paid"
  end

  def cancelled?
    status == "cancelled"
  end

  def formatted_total
    "$#{total_amount.to_f.round(2)}"
  end

  def formatted_final_amount
    "$#{final_amount.to_f.round(2)}"
  end

  def payment_method_display
    payment_method&.humanize || "Not specified"
  end

  # Tax and service charge calculations
  def calculate_tax_amount
    (total_amount * 0.10).round(2) # 10% tax
  end

  def calculate_service_charge
    (total_amount * 0.05).round(2) # 5% service charge
  end

  def calculate_final_amount
    total_amount + calculate_tax_amount + calculate_service_charge
  end

  # Auto-calculate if not set
  def tax_amount
    super || calculate_tax_amount
  end

  def service_charge
    super || calculate_service_charge
  end

  def final_amount
    super || calculate_final_amount
  end
end
