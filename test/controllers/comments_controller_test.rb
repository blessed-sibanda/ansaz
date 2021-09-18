require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create :user
    @comment = create :comment, user: @user
    sign_in @user
  end

  test "should create comment on answer" do
    answer = create :answer
    assert_difference("Comment.count") do
      post comments_url,
           params: { comment: { content: "Blah blah",
                               commentable_id: answer.id,
                               commentable_type: "Answer",
                               answer_id: answer.parent_answer.id } },
           xhr: true
    end
  end

  test "should create comment on another comments" do
    assert_difference("Comment.count") do
      post comments_url,
           params: { comment: { content: "Blah blah",
                               commentable_id: @comment.id,
                               commentable_type: "Comment",
                               answer_id: @comment.parent_answer.id } },
           xhr: true
    end
  end

  test "comment owner can destroy comment" do
    assert_difference("Comment.count", -1) do
      delete comment_url(@comment), xhr: true
    end
  end

  test "non comment owner cannot destroy comment" do
    random_comment = create :comment
    assert_no_difference("Comment.count") do
      delete comment_url(random_comment), xhr: true
    end
  end
end
