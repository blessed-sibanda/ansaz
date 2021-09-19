require "test_helper"

class GroupMembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = create :group
    @user = create(:user)
    sign_in @user
  end

  test "should join group" do
    assert_difference "GroupMembership.count" do
      patch group_membership_url(@group)
    end
  end

  test "regular member should leave group" do
    create :group_membership, group: @group, user: @user
    assert_difference "GroupMembership.count", -1 do
      delete group_membership_url(@group)
      assert_equal flash[:alert], "You have left '#{@group.name}' group"
    end
  end

  test "admin member should not leave group" do
    create :group_membership, group: @group, user: @user
    @group.admin = @user
    @group.save!
    assert_no_difference "GroupMembership.count" do
      delete group_membership_url(@group)
      assert_equal flash[:alert], "Group admin cannot leave"
    end
  end

  test "admin can accept member to join group" do
    @group.admin = @user
    @group.save!
    membership = create :group_membership, :pending, group: @group
    assert_equal membership.state, GroupMembership::PENDING
    post accept_group_membership_path(membership)
    assert_equal membership.reload.state, GroupMembership::ACCEPTED
  end

  test "non-admin cannot accept member to join group" do
    membership = create :group_membership, :pending, group: @group
    assert_equal membership.state, GroupMembership::PENDING
    post accept_group_membership_path(membership)
    assert_equal flash[:alert], "Only group admin can accept or reject group join requests."
    assert_equal membership.reload.state, GroupMembership::PENDING
  end

  test "admin can reject member to join group" do
    @group.admin = @user
    @group.save!
    membership = create :group_membership, :pending, group: @group
    assert_equal membership.state, GroupMembership::PENDING
    assert_difference "GroupMembership.count", -1 do
      delete reject_group_membership_path(membership)
    end
  end

  test "non-admin cannot reject member to join group" do
    membership = create :group_membership, :pending, group: @group
    assert_equal membership.state, GroupMembership::PENDING
    assert_no_difference "GroupMembership.count" do
      delete reject_group_membership_path(membership)
      assert_equal flash[:alert], "Only group admin can accept or reject group join requests."
    end
  end
end
