require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  setup do
    @user = create :user
    @question = create :question
    create_list :answer, 3, question: @question
    @answer = Answer.all.sample
    login_as @user
  end

  test "commenting on answers" do
    visit question_url(@question)

    # the modal is closed by default
    assert_no_selector ".modal-open"

    # the answer comments are also hidden initially
    answer_comments_selector = "#answer_#{@answer.id}_comments"
    assert_no_selector answer_comments_selector

    within "#answer_#{@answer.id}" do
      click_on "Reply"
    end

    assert_selector ".modal-open"

    fill_in "Content", with: "Well answered"
    click_on "Create Comment"

    # after creating a comment, the answer comments are now visible
    assert_selector answer_comments_selector

    within "#answer_#{@answer.id}" do
      # the # of comments is now displayed
      assert_text "replies (1)"
      within answer_comments_selector do
        # the newly added comment text is displayed
        c1 = Comment.last
        assert_text c1.content
        assert_selector "#comment_#{c1.id}"

        # user can also comment on the comment
        click_on "Reply"

        fill_in "Content", with: "Comment on another comment"
        click_on "Create Comment"

        # Child comment is displayed within parent comment
        c2 = Comment.last
        assert_selector "#comment_#{c1.id}" do
          assert_selector "#comment_#{c2.id}"
        end
      end

      c1 = Comment.first
      c2 = Comment.last

      # Clicking on `replies` link toggles the visibility of the comments
      click_on "Replies (1)"
      assert_no_selector answer_comments_selector
      click_on "Replies (1)"
      assert_selector answer_comments_selector

      # All comments are displayed
      assert_selector "#comment_#{c1.id}"
      assert_selector "#comment_#{c2.id}"

      # User can delete his/her comment
      # Deleting a comment also deletes the child comments
      within "#comment_#{c1.id}" do
        page.accept_confirm do
          click_on "delete", match: :first
        end
      end

      # Comment has been deleted
      assert_no_selector "#comment_#{c1.id}"

      # Child comment deleted as well
      assert_no_selector "#comment_#{c2.id}"
    end
  end
end
