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

  def leave?
    return false if user == record.admin # the admin cannot leave
    GroupMembership.accepted.where(user: user,
                                   group: record).any?
  end

  def join?
    GroupMembership.where(user: user,
                          group: record).empty?
  end

  def participate?
    record.active_users.include? user
  end
end
