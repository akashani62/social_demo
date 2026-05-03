require "test_helper"

class PostsShowViewTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
  end

  test "guest sees sign in to comment" do
    get post_url(@post)
    assert_response :success
    assert_select "a", text: "Sign in to comment"
    assert_select "a", text: "Add a comment", count: 0
    assert_select "a", text: "Edit this post", count: 0
  end

  test "owner sees add comment and edit post" do
    sign_in_as(users(:one))

    get post_url(@post)
    assert_response :success
    assert_select "a", text: "Add a comment"
    assert_select "a", text: "Sign in to comment", count: 0
    assert_select "a", text: "Edit this post"
    assert_select "button", text: "Destroy this post"
  end

  test "non-owner does not see post edit controls" do
    sign_in_as(users(:two))

    get post_url(@post)
    assert_response :success
    assert_select "a", text: "Edit this post", count: 0
    assert_select "button", text: "Destroy this post", count: 0
  end
end
