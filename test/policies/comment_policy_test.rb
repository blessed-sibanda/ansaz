require "test_helper"

class CommentPolicyTest < PolicyAssertions::Test
  def test_destroy
    comment = create :comment
    assert_permit comment.user, comment
    refute_permit create(:user), comment
  end
end
