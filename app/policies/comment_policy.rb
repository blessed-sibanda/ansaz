class CommentPolicy < ApplicationPolicy
  def destroy?
    user == record.user
  end
end
