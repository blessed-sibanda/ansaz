require "test_helper"

class GroupPolicyTest < PolicyAssertions::Test
  def setup
    @group = create :group
    @membership = create(:group_membership, :accepted, group: @group)
  end

  def test_edit_and_update_and_destroy
    assert_permit @group.admin, @group
    refute_permit create(:user), @group
    refute_permit nil, @group
  end

  def test_leave
    refute_permit @group.admin, @group
    assert_permit @membership.user, @group
  end

  def test_join
    refute_permit @membership.user, @group
    assert_permit create(:user), @group
  end

  def test_participate
    assert_permit @membership.user, @group
    assert_permit @group.admin, @group
    refute_permit create(:user), @group
  end
end
