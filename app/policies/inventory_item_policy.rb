class InventoryItemPolicy < ApplicationPolicy
  def index?
    user.present? && user.can_manage_inventory?
  end

  def show?
    user.present? && user.can_manage_inventory?
  end

  def create?
    user.present? && user.can_manage_inventory?
  end

  def update?
    user.present? && user.can_manage_inventory?
  end

  def destroy?
    user.present? && user.can_manage_inventory?
  end

  class Scope < Scope
    def resolve
      if user.can_manage_inventory?
        scope.all
      else
        scope.none
      end
    end
  end
end