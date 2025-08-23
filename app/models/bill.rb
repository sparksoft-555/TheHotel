class Bill < ApplicationRecord
  belongs_to :order

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_status, inclusion: { in: %w[pending paid cancelled] }

  PAYMENT_STATUSES = %w[pending paid cancelled].freeze
  PAYMENT_METHODS = %w[cash credit_card debit_card mobile_payment].freeze

  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, allow_blank: true

  scope :pending, -> { where(payment_status: "pending") }
  scope :paid, -> { where(payment_status: "paid") }
  scope :for_date, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }

  def mark_as_paid!(method = "cash")
    update!(
      payment_status: "paid",
      payment_method: method,
      paid_at: Time.current
    )
  end

  def cancel!
    update!(payment_status: "cancelled")
  end

  def pending?
    payment_status == "pending"
  end

  def paid?
    payment_status == "paid"
  end

  def cancelled?
    payment_status == "cancelled"
  end

  def formatted_total
    "$#{total_amount.to_f.round(2)}"
  end

  def payment_method_display
    payment_method&.humanize || "Not specified"
  end

  # Calculate tax (assuming 8.5% tax rate)
  def tax_amount
    (total_amount * 0.085).round(2)
  end

  def subtotal
    (total_amount / 1.085).round(2)
  end
end
