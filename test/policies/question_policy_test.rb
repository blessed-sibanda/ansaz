require "test_helper"

class QuestionPolicyTest < PolicyAssertions::Test
  def test_update_and_destroy
    q = create :question
    assert_permit q.user, q
    refute_permit create(:user), q
  end
end
