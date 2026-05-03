require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @comment = comments(:one)
  end

  test "should get index" do
    get comments_url
    assert_response :success
  end

  test "guest cannot get new" do
    get new_comment_url
    assert_redirected_to sign_in_url
  end

  test "signed in user can get new" do
    sign_in_as(users(:one))
    get new_comment_url
    assert_response :success
  end

  test "guest cannot create comment" do
    assert_no_difference("Comment.count") do
      post comments_url, params: { comment: { body: "Nope", post_id: @comment.post_id } }
    end

    assert_redirected_to sign_in_url
  end

  test "should create comment when signed in" do
    sign_in_as(users(:two))

    assert_difference("Comment.count") do
      post comments_url, params: { comment: { body: "Fresh insight", post_id: @comment.post_id } }
    end

    assert_redirected_to post_url(Comment.last.post)
    assert_equal users(:two).id, Comment.last.user_id
  end

  test "creates comment via turbo stream from modal frame" do
    sign_in_as(users(:two))

    assert_difference("Comment.count", 1) do
      post comments_url,
           params: { comment: { body: "Modal streamed", post_id: @comment.post_id } },
           headers: {
             "Accept" => "text/vnd.turbo-stream.html",
             "Turbo-Frame" => "new_comment_modal"
           }
    end

    assert_response :success
    assert_includes response.media_type, "turbo-stream"
    assert_match(/turbo-stream/, response.body)
  end

  test "should show comment" do
    get comment_url(@comment)
    assert_response :success
  end

  test "guest cannot get edit" do
    get edit_comment_url(@comment)
    assert_redirected_to sign_in_url
  end

  test "owner can get edit" do
    sign_in_as(users(:one))
    get edit_comment_url(@comment)
    assert_response :success
  end

  test "non-owner is redirected from edit" do
    sign_in_as(users(:two))

    get edit_comment_url(@comment)
    assert_redirected_to post_url(@comment.post)
  end

  test "owner can update comment" do
    sign_in_as(users(:one))

    patch comment_url(@comment), params: { comment: { body: "Updated comment copy" } }

    assert_redirected_to post_url(@comment.post)
    assert_equal "Updated comment copy", @comment.reload.body
  end

  test "guest cannot update comment" do
    patch comment_url(@comment), params: { comment: { body: "Broken in" } }

    assert_redirected_to sign_in_url
  end

  test "non-owner cannot update comment" do
    sign_in_as(users(:two))
    original_body = @comment.body

    patch comment_url(@comment), params: { comment: { body: "Should not persist" } }

    assert_redirected_to post_url(@comment.post)
    assert_equal original_body, @comment.reload.body
  end

  test "owner can destroy comment" do
    sign_in_as(users(:one))
    post_record = @comment.post

    assert_difference("Comment.count", -1) do
      delete comment_url(@comment)
    end

    assert_redirected_to post_url(post_record)
  end

  test "guest cannot destroy comment" do
    assert_no_difference("Comment.count") do
      delete comment_url(@comment)
    end

    assert_redirected_to sign_in_url
  end

  test "non-owner cannot destroy comment" do
    sign_in_as(users(:two))

    assert_no_difference("Comment.count") do
      delete comment_url(@comment)
    end

    assert_redirected_to post_url(@comment.post)
  end
end
