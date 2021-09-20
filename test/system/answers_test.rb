require "application_system_test_case"

class AnswersTest < ApplicationSystemTestCase
  setup do
    @answer = create :answer
  end

  test "creating an Answer" do
    login_as @answer.user
    visit question_url(@answer.question)

    find("trix-editor").set("The answer is 43")
    click_on "Create Answer"

    assert_text "Answer was successfully created"
    assert_equal Answer.last.content.to_plain_text, "The answer is 43"
  end

  test "destroying an Answer" do
    login_as @answer.user
    visit question_url(@answer.question)

    assert_equal Answer.count, 1
    within "#answer_#{@answer.id}" do
      page.accept_confirm do
        click_on "delete", match: :first
      end
    end

    assert_no_selector "#answer_#{@answer.id}"
  end

  test "starring an Answer" do
    login_as @answer.user
    visit question_url(@answer.question)
    within "#answer_#{@answer.id}_stars" do
      click_on "0 stars"
      assert_text "1 star"
      click_on "1 star"
      assert_text "0 stars"
    end
  end

  test "marking an Answer as accepted" do
    login_as @answer.question.user
    visit question_url(@answer.question)
    within "#answer_#{@answer.id}" do
      assert_no_selector "span.badge.bg-success"
      click_on "accept"
      assert_selector "span.badge.bg-success"
      click_on "reject"
      assert_no_selector "span.badge.bg-success"
    end
  end
end
