class OrderPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && (user.admin? || user.manager? || user.chef? || user.cashier? || own_order?)
  end

  def create?
    user.present?
  end

  def update?
    user.present? && (user.admin? || user.manager?)
  end

  def update_status?
    user.present? && (user.admin? || user.chef?)
  end

  def kitchen?
    user.present? && (user.admin? || user.chef?)
  end

  def advance_status?
    user.present? && (user.admin? || user.chef?)
  end

  private

  def own_order?
    user.customer? && record.customer_id == user.id
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.manager?
        scope.all
      elsif user.chef?
        scope.for_kitchen
      elsif user.cashier?
        scope.ready_for_delivery
      elsif user.customer?
        scope.where(customer: user)
      else
        scope.none
      end
    end
  end
end