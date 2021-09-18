class AnswerPolicy < ApplicationPolicy
  def accept?
    user == record.question.user
  end

  def destroy?
    user == record.user
  end
end
