require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  def login_as(user)
    visit new_user_session_url
    fill_in "Email", with: user.email
    fill_in "Password", with: "1234pass"
    click_button "Log in"
  end
end
