require "application_system_test_case"

class QuestionsTest < ApplicationSystemTestCase
  setup do
    @question = create :question
  end

  test "visiting the index" do
    login_as @question.user
    visit questions_url
    assert_selector "h1", text: "QUESTIONS"
  end

  test "creating a Question" do
    login_as @question.user
    visit questions_url
    click_on "New Question"

    fill_in "Title", with: "What is the purpose of life"
    fill_in "question[tag_list]", with: "life,purpose"
    find("trix-editor").set("I am trying to find my life purpose")
    click_on "Create Question"

    assert_text "Question was successfully created"
  end

  test "updating a Question" do
    login_as @question.user
    visit questions_url
    click_on "Edit", match: :first

    fill_in "Title", with: @question.title
    fill_in "question[tag_list]", with: "life,purpose"
    click_on "Update Question"

    assert_text "Question was successfully updated"
  end

  test "destroying a Question" do
    login_as @question.user
    visit questions_url
    page.accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "Question was successfully destroyed"
  end
end
