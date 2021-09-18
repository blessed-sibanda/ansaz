require "test_helper"

class AnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @answer = create :answer
    @user = @answer.user
    @question_id = @answer.question.id
    sign_in(@user)
  end

  test "should create answer" do
    assert_difference("Answer.count") do
      post question_answers_url(question_id: @question_id), params: { answer: { content: "Blah blah" } }
    end

    assert_redirected_to question_url(@answer.question)
  end

  test "should destroy answer" do
    assert_difference("Answer.count", -1) do
      delete question_answer_url(@answer.question, @answer), xhr: true
    end
  end

  test "only answer owner can destroy the answer" do
    other_answer = create(:answer)
    assert_no_difference "Answer.count" do
      delete question_answer_url(other_answer.question, other_answer)
    end
  end
end
