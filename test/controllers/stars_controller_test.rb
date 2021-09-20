require "test_helper"

class StarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create :user
    @question = create :question
    sign_in @user
  end

  test "should create star" do
    assert_equal @question.stars.count, 0
    post stars_url,
         params: { starrable_id: @question.id,
                   starrable_type: @question.class.name },
         xhr: true
    assert_equal @question.stars.count, 1
  end

  test "user can remove his/her own star" do
    star = create :star, user: @user
    assert_difference "Star.count", -1 do
      delete star_url(star), xhr: true
    end
  end

  test "user cannot remove others' stars" do
    star = create :star
    assert_no_difference "Star.count" do
      delete star_url(star), xhr: true
      assert_equal flash[:alert], "You cannot perform this action."
    end
  end
end
