class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Roles for the hotel management system - Updated to match specification
  enum role: { 
    admin: 'admin', 
    manager: 'manager', 
    chef: 'chef',           # Changed from 'kitchen' to 'chef'
    cashier: 'cashier',     # Added cashier role
    accountant: 'accountant', 
    customer: 'customer' 
  }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :role, inclusion: { in: roles.keys }

  # Employee-related associations
  has_many :work_logs, dependent: :destroy
  has_many :orders, foreign_key: "customer_id", dependent: :nullify

  scope :employees, -> { where.not(role: "customer") }
  scope :customers, -> { where(role: "customer") }
  scope :kitchen_staff, -> { where(role: "chef") }
  scope :cashiers, -> { where(role: "cashier") }
  scope :managers, -> { where(role: "manager") }

  def employee?
    role != "customer"
  end

  def can_manage_system?
    admin?
  end

  def can_manage_restaurant?
    %w[admin manager].include?(role)
  end

  def can_cook?
    chef?
  end

  def can_handle_payments?
    %w[cashier accountant admin].include?(role)
  end

  def can_view_financial_reports?
    %w[accountant manager admin].include?(role)
  end

  def can_manage_inventory?
    %w[manager admin].include?(role)
  end

  def can_create_menus?
    %w[manager admin].include?(role)
  end
end
