class UserPolicy < ApplicationPolicy
  def index?
    user.present? && user.can_manage_system?
  end

  def show?
    user.present? && (user.can_manage_system? || own_profile?)
  end

  def create?
    user.present? && user.can_manage_system?
  end

  def update?
    user.present? && (user.can_manage_system? || own_profile?)
  end

  def destroy?
    user.present? && user.can_manage_system? && !own_profile?
  end

  def manage_employees?
    user.present? && user.can_manage_restaurant?
  end

  private

  def own_profile?
    user == record
  end

  class Scope < Scope
    def resolve
      if user.can_manage_system?
        scope.all
      elsif user.can_manage_restaurant?
        scope.employees
      else
        scope.where(id: user.id)
      end
    end
  end
end