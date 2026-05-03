require "test_helper"

class PostsShowViewTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
  end

  test "guest sees sign in to comment" do
    get post_url(@post)
    assert_response :success
    assert_select "a", text: "Sign in to comment"
    assert_select "button", text: "Add comment", count: 0
    assert_select "a", text: "Edit on full page", count: 0
  end

  test "owner sees add comment modal trigger and post actions" do
    sign_in_as(users(:one))

    get post_url(@post)
    assert_response :success
    assert_select "button", text: "Add comment"
    assert_select "a", text: "Sign in to comment", count: 0
    assert_select "a", text: "Edit on full page"
    assert_select "button", text: "Delete post"
    assert_select "turbo-frame#new_comment_modal"
  end

  test "non-owner does not see post edit controls" do
    sign_in_as(users(:two))

    get post_url(@post)
    assert_response :success
    assert_select "a", text: "Edit on full page", count: 0
    assert_select "button", text: "Delete post", count: 0
  end
end
