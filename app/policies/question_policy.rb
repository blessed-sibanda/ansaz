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

  def view?
    # anyone can view a question whose group is nil
    # group questions can only be viewed by group participants
    # the question asker always has access to his/her question even if he/she leaves the group
    record.group.nil? || GroupPolicy.new(user, record.group).participate? || record.user == user
  end
end
