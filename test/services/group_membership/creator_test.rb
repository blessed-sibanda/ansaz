require "test_helper"

class GroupMembership::CreatorTest < ActiveSupport::TestCase
  test "joining a public group" do
    g = create :group, :public
    u = create :user
    assert_difference "GroupMembership.count", 1 do
      message = GroupMembership::Creator.call(user: u, group: g)
      assert_equal message, "You have joined '#{g.name}' group"
      assert_equal GroupMembership.last.state, GroupMembership::ACCEPTED
    end
  end

  test "joining a private group" do
    g = create :group, :private
    u = create :user
    assert_difference "GroupMembership.count", 1 do
      message = GroupMembership::Creator.call(user: u, group: g)
      assert_equal message, "A request to join '#{g.name}' has been sent"
      assert_equal GroupMembership.last.state, GroupMembership::PENDING
    end
  end

  test "group admin is already in the group" do
    g = create :group, :private
    assert_difference "GroupMembership.count", 0 do
      message = GroupMembership::Creator.call(user: g.admin, group: g)
      assert_equal message, "You are already in this group"
      assert_equal GroupMembership.last.state, GroupMembership::ACCEPTED
    end
  end
end
