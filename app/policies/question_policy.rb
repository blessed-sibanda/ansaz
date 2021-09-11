class QuestionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def update?
    user == record.user
  end

  def destroy?
    user == record.user
  end
end
