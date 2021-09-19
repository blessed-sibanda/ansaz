class GroupMembership::Creator < ApplicationService
  attr_reader :user, :group, :state, :result_message
  private :user, :group, :state, :result_message

  def initialize(user:, group:)
    @user = user
    @group = group
    set_membership_state
  end

  def call
    membership = GroupMembership.find_or_initialize_by(
      state: @state, user: @user, group: @group
    )
    if membership.persisted?
      @result_message = 'You are already in this group'
    else
      membership.save!
    end
    @result_message
  end

  private

  def set_membership_state
    if group.admin == user
      @state = GroupMembership::ACCEPTED
      return
    end
    case group.group_type
    when Group::PUBLIC
      @state = GroupMembership::ACCEPTED
      @result_message = "You have joined '#{group.name}' group"
    when Group::PRIVATE
      @state = GroupMembership::PENDING
      @result_message = "A request to join '#{group.name}' has been sent"
    else
      # type code here
    end
  end
end
