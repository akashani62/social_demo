require "test_helper"

class SharesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    ActionMailer::Base.deliveries.clear
  end

  test "guest cannot create share" do
    assert_no_difference("Share.count") do
      post post_shares_url(@post), params: { share: { recipient_email: "friend@example.com" } }
    end

    assert_redirected_to sign_in_url
  end

  test "signed in user can share a post" do
    sign_in_as(users(:one))

    assert_difference("Share.count", 1) do
      post post_shares_url(@post), params: { share: { recipient_email: "friend@example.com" } }
    end

    assert_redirected_to post_url(@post)
    assert_equal "Post shared successfully.", flash[:notice]
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test "signed in user sees service error on duplicate share" do
    sign_in_as(users(:one))
    Share.create!(post: @post, user: users(:one), recipient_email: "friend@example.com")

    assert_no_difference("Share.count") do
      post post_shares_url(@post), params: { share: { recipient_email: "FRIEND@example.com" } }
    end

    assert_redirected_to post_url(@post)
    assert_includes flash[:alert], "already shared"
  end
end
