require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @question = create :question
    @user = @question.user
    sign_in(@user)
  end

  test "should get index" do
    get questions_url
    assert_response :success
  end

  test "unauthenticated user cannot view the questions" do
    sign_out @user
    get questions_url
    assert_redirected_to new_user_session_url
  end

  test "index paginates the questions" do
    create_list :question, 50
  end

  test "should get new" do
    get new_question_url
    assert_response :success
  end

  test "should create question" do
    assert_difference("Question.count") do
      post questions_url, params: { question: { title: @question.title, user_id: @question.user_id } }
    end

    assert_redirected_to question_url(Question.last)
  end

  test "should show question" do
    get question_url(@question)
    assert_response :success
  end

  test "should get edit" do
    get edit_question_url(@question)
    assert_response :success
  end

  test "should update question" do
    patch question_url(@question), params: { question: { title: @question.title, user_id: @question.user_id } }
    assert_redirected_to question_url(@question)
  end

  test "should destroy question" do
    assert_difference("Question.count", -1) do
      delete question_url(@question)
    end

    assert_redirected_to questions_url
  end
end
