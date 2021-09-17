require "test_helper"

class GroupMembershipPolicyTest < PolicyAssertions::Test
  def test_accept_or_reject
    g = create(:group)
    gm = create :group_membership, group: g
    assert_permit g.admin, gm
    refute_permit create(:user), gm
    refute_permit nil, gm
  end
end
