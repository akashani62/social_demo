require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get sign in page" do
    get sign_in_url
    assert_response :success
  end

  test "should sign in with valid credentials" do
    post sign_in_url, params: { session: { email: @user.email, password: SessionTestHelper::FIXTURE_USER_PASSWORD } }

    assert_redirected_to root_url
    assert_equal @user.id, session[:user_id]
  end

  test "should reject invalid password" do
    post sign_in_url, params: { session: { email: @user.email, password: "wrong-password" } }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should sign out" do
    sign_in_as(@user)
    delete sign_out_url

    assert_redirected_to root_url
    assert_nil session[:user_id]
  end
end
