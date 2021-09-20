require "application_system_test_case"

class UserProfilesTest < ApplicationSystemTestCase
  setup do
    @user = create :user
    @user_questions = create_list :question, 6, user: @user
    @user_answers = create_list :answer, 4, user: @user
    group = create :group, :private, admin: @user
    @requests = create_list :group_membership, 3, :pending, group: group
    login_as @user
  end

  def login_as(user)
    visit new_user_session_url
    fill_in "Email", with: user.email
    fill_in "Password", with: "1234pass"
    click_button "Log in"
  end

  test "visiting own user profile" do
    visit user_url(@user)
    assert_selector "div", text: @user.about

    within ".nav-tabs" do
      click_on "Questions"
    end

    within ".tab-content" do
      assert_selector "a.card-title", count: 6
      @user_questions.each do |q|
        assert_selector "a.card-title", text: q.title
      end
    end

    within ".nav-tabs" do
      click_on "Answers"
    end

    within ".tab-content" do
      @user_answers.each do |a|
        assert_selector "a", text: a.content
      end
    end

    within ".nav-tabs" do
      click_on "Requests"
    end

    within ".tab-content" do
      @requests.each do |m|
        within "#group_membership_#{m.id}" do
          assert_selector "a", text: m.group.name
          assert_selector "a", text: "accept"
          assert_selector "a", text: "reject"
        end
      end
    end
  end
end
