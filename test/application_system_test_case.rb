require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SessionTestHelper

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 900]

  setup do
    Capybara.default_max_wait_time = 10
  end

  def sign_in_via_browser(user)
    visit sign_in_path
    fill_in "Email", with: user.email
    fill_in "Password", with: SessionTestHelper::FIXTURE_USER_PASSWORD
    click_button "Sign in"
    assert_selector "button", text: "Sign out", wait: 10
  end
end
