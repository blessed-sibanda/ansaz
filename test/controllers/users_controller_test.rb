require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create :user
    sign_in @user
  end

  test "#index should return paginated users list" do
    create_list :user, 45
    get users_url
    assert_response :success
    page1 = User.active.ranked.paginate(per_page: 20, page: 1)

    page1.each do |u|
      assert_select "a[href=?]", user_path(u), u.name
    end

    assert_select "nav>ul.pagination" do
      assert_select "li>a[href=?]", users_path(page: 2)
      assert_select "li>a[href=?]", users_path(page: 3)
    end
  end

  test "#index should not return unconfirmed users" do
    unconfirmed_users = create_list :user, 45, :unconfirmed
    get users_url
    assert_response :success
    unconfirmed_users.each do |u|
      assert_select "a[href=?]", user_path(u), count: 0
    end
  end

  test "should get show" do
    get user_url(@user)
    assert_response :success
    assert_select "div", @user.about
  end
end
