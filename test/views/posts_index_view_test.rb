require "test_helper"

class PostsIndexViewTest < ActionDispatch::IntegrationTest
  include ActionView::RecordIdentifier

  test "renders heading and empty state" do
    Comment.delete_all
    Post.delete_all

    get posts_url
    assert_response :success
    assert_select "h1", text: "Posts"
    assert_select "#posts-empty", text: /No posts yet/
  end

  test "guest sees sign in to post instead of new post" do
    get posts_url
    assert_response :success
    assert_select "a", text: "Sign in to post"
    assert_select "button", text: "New post", count: 0
  end

  test "owner sees new post button and turbo frame" do
    sign_in_as(users(:one))

    get posts_url
    assert_response :success
    assert_select "button", text: "New post"
    assert_select "turbo-frame#new_post_modal"
  end

  test "signed in non-owner does not see edit on others posts" do
    sign_in_as(users(:two))

    get posts_url
    assert_response :success
    assert_select "button", text: "New post"
    assert_select "turbo-frame##{dom_id(posts(:one))} a", text: "Edit", count: 0
    assert_select "turbo-frame##{dom_id(posts(:two))} a", text: "Edit"
  end
end
