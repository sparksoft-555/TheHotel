class MenuItemPolicy < ApplicationPolicy
  def index?
    true # Everyone can view menu items
  end

  def show?
    true # Everyone can view individual menu items
  end

  def create?
    user.present? && user.can_create_menus?
  end

  def update?
    user.present? && user.can_create_menus?
  end

  def destroy?
    user.present? && user.can_create_menus?
  end

  class Scope < Scope
    def resolve
      scope.all # Menu items are visible to everyone
    end
  end
end