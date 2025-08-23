class User < ApplicationRecord
  has_secure_password

  # Roles for the hotel management system
  ROLES = %w[customer manager chef cashier accountant].freeze

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :role, inclusion: { in: ROLES }

  # Employee-related associations
  has_many :work_logs, dependent: :destroy
  has_many :orders, foreign_key: "customer_id", dependent: :nullify

  scope :employees, -> { where.not(role: "customer") }
  scope :customers, -> { where(role: "customer") }

  def employee?
    role != "customer"
  end

  def can_manage?
    role == "manager"
  end

  def can_cook?
    role == "chef"
  end

  def can_handle_payments?
    %w[cashier accountant].include?(role)
  end
end
