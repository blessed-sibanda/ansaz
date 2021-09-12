class StarPolicy < ApplicationPolicy
  def destroy?
    user == record.user
  end
end
