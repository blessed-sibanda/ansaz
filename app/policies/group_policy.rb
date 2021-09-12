class GroupPolicy < ApplicationPolicy
  def update?
    user == record.admin
  end

  def destroy?
    user == record.admin
  end

  def edit?
    user == record.admin
  end
end
