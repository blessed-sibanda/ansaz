require "test_helper"

class StarPolicyTest < PolicyAssertions::Test
  def test_destroy
    s = create :star
    assert_permit s.user, s
    refute_permit create(:user), s
  end
end
