class GroupMembershipPolicy < ApplicationPolicy
  def accept_or_reject?
    user == record.group.admin
  end
end
