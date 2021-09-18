require "test_helper"

class AnswerPolicyTest < PolicyAssertions::Test
  def test_accept
    question = create(:question)
    answer = create(:answer, question: question)

    assert_permit question.user, answer
    refute_permit create(:user), answer
    refute_permit nil, answer
  end

  def test_destroy
    answer = create(:answer)

    assert_permit answer.user, answer
    refute_permit create(:user), answer
    refute_permit nil, answer
  end
end
