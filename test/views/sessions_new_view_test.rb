require "test_helper"

class SessionsNewViewTest < ActionDispatch::IntegrationTest
  test "renders sign in heading and form fields" do
    get sign_in_url
    assert_response :success
    assert_select "h1", text: "Sign in"
    assert_select "form" do
      assert_select "input#session_email[name=?]", "session[email]"
      assert_select "input#session_password[name=?]", "session[password]"
      assert_select "input[type=submit][value=?]", "Sign in"
    end
  end

  test "links to user registration" do
    get sign_in_url
    assert_response :success
    assert_select "a[href=?]", new_user_path, text: "Create a user"
  end
end
