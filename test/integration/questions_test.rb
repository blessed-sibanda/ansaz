require "test_helper"

class QuestionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  def assert_question_info(q)
    assert_select "#question_#{q.id}" do
      assert_select "a[href=?]", question_path(q), text: q.title
      assert_select "img", count: 1
      if Pundit.policy!(@user, q).edit?
        assert_select "a[href=?]", question_path(q), text: "Edit"
      end
      if Pundit.policy!(@user, q).destroy?
        assert_select "a[href=?]", question_path(q), text: "Delete"
      end

      q.tags.each do |tag|
        assert_select "a[href=?]", tag_path(tag), text: "##{tag.name}"
      end

      assert_select "#question_#{q.id}_stars" do
        assert_select "a", %r{#{q.stars.count} star}
      end
    end
  end

  test "questions are paginated" do
    sign_in @user
    create_list :question, 25
    get questions_url
    page1 = Question.paginated(1)
    page1.each { |q| assert_question_info(q) }

    assert_select "nav>ul.pagination" do
      assert_select "li>a[href=?]", questions_path(page: 2)
      assert_select "li>a[href=?]", questions_path(page: 3)
    end
  end

  test "question page displays the answers" do
    sign_in @user
    q = create :question
    create_list :answer, 5, question: q
    get question_path(q)
    assert_question_info(q)
    assert_select "div", text: q.content.to_plain_text

    q.answers.ranked.each do |a|
      assert_select "#answer_#{a.id}" do
        assert_select "div", a.content.to_plain_text
      end
    end
  end
end
