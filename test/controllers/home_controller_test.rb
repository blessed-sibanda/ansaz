require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "index redirects unauthenticated users to login page" do
    get root_url
    assert_redirected_to new_user_session_url
  end

  test "index redirects authenticated users to questions page" do
    sign_in create(:user)
    get root_url
    assert_redirected_to questions_url
  end
end
