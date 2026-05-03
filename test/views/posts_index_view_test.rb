require "test_helper"

class PostsIndexViewTest < ActionDispatch::IntegrationTest
  test "renders heading and empty state" do
    Post.delete_all

    get posts_url
    assert_response :success
    assert_select "h1", text: "Posts"
    assert_select "p", text: "No posts found."
  end

  test "guest sees sign in to post instead of new post" do
    get posts_url
    assert_response :success
    assert_select "a", text: "Sign in to post"
    assert_select "a", text: "New post", count: 0
    assert_select "a", text: "Edit", count: 0
  end

  test "owner sees new post and edit controls" do
    sign_in_as(users(:one))

    get posts_url
    assert_response :success
    assert_select "a", text: "New post"
    assert_select "a", text: "Sign in to post", count: 0
    assert_select "a", text: "Edit"
  end

  test "signed in non-owner does not see edit for others posts" do
    sign_in_as(users(:two))

    get posts_url
    assert_response :success
    assert_select "a", text: "New post"
    assert_select "a", text: "Edit", count: 0
  end
end
