class AnswerPolicy < ApplicationPolicy
  def accept?
    user == record.question.user
  end
end
