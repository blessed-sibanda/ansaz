class AnswerPolicy < ApplicationPolicy
  def accept_or_reject?
    user == record.question.user
  end

  def destroy?
    user == record.user
  end
end
