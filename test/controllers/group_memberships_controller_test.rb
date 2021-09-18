require "test_helper"

class GroupMembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = create :group
  end
  test "#update should join group" do
    assert_difference "GroupMembership.count", 1 do
      put group_membership_url()
    end
  end
end
