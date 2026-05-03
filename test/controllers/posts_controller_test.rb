require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "guest cannot get new" do
    get new_post_url
    assert_redirected_to sign_in_url
  end

  test "signed in user can get new" do
    sign_in_as(users(:one))
    get new_post_url
    assert_response :success
  end

  test "guest cannot create post" do
    assert_no_difference("Post.count") do
      post posts_url, params: { post: { body: "Body", title: "Guest tried" } }
    end

    assert_redirected_to sign_in_url
  end

  test "should create post when signed in as author" do
    sign_in_as(users(:one))

    assert_difference("Post.count") do
      post posts_url, params: { post: { body: "Body", title: "Authored via session" } }
    end

    assert_redirected_to post_url(Post.last)
    assert_equal users(:one).id, Post.last.user_id
  end

  test "should show post" do
    get post_url(@post)
    assert_response :success
  end

  test "guest cannot get edit" do
    get edit_post_url(@post)
    assert_redirected_to sign_in_url
  end

  test "owner can get edit" do
    sign_in_as(users(:one))
    get edit_post_url(@post)
    assert_response :success
  end

  test "non-owner is redirected from edit" do
    sign_in_as(users(:two))

    get edit_post_url(@post)
    assert_redirected_to post_url(@post)
  end

  test "guest cannot update post" do
    patch post_url(@post), params: { post: { body: @post.body, title: @post.title } }

    assert_redirected_to sign_in_url
  end

  test "non-owner cannot update post" do
    sign_in_as(users(:two))
    original_title = @post.title

    patch post_url(@post), params: { post: { body: "Unauthorized", title: "Unauthorized title" } }

    assert_redirected_to post_url(@post)
    assert_equal original_title, @post.reload.title
  end

  test "owner can update post" do
    sign_in_as(users(:one))

    patch post_url(@post), params: { post: { body: @post.body, title: @post.title } }

    assert_redirected_to post_url(@post)
  end

  test "guest cannot destroy post" do
    assert_no_difference("Post.count") do
      delete post_url(@post)
    end

    assert_redirected_to sign_in_url
  end

  test "non-owner cannot destroy post" do
    sign_in_as(users(:two))

    assert_no_difference("Post.count") do
      delete post_url(@post)
    end

    assert_redirected_to post_url(@post)
  end

  test "owner can destroy post" do
    sign_in_as(users(:one))

    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end
end
