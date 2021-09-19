require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in create(:user)
    get search_index_url
    assert_response :success
  end
end
