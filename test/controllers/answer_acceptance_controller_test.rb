require "test_helper"

class AnswerAcceptanceControllerTest < ActionDispatch::IntegrationTest
  setup do
    @answer = create :answer
    sign_in @answer.question.user
  end

  test "question asker should accept answer" do
    refute @answer.accepted?
    patch answer_acceptance_path(@answer), xhr: true
    assert @answer.reload.accepted?
  end

  test "others cannot accept answer" do
    sign_in create(:user)
    refute @answer.accepted?
    patch answer_acceptance_path(@answer), xhr: true
    refute @answer.reload.accepted?
    assert_equal flash[:alert], "Only the owner of the question can mark answers as accepted or rejected."
  end

  test "should reject answer" do
    refute @answer.accepted?
    @answer.accepted = true
    @answer.save!
    delete answer_acceptance_path(@answer), xhr: true
    refute @answer.reload.accepted?
  end
end
