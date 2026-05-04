require "test_helper"

class SharePostTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "creates share and sends email when inputs are valid" do
    result = nil

    assert_difference("Share.count", 1) do
      result = SharePost.new(
        post_id: posts(:one).id,
        recipient_email: " Friend@Example.com ",
        sender: users(:one)
      ).call
    end

    assert result.success?
    assert_equal [], result.errors
    assert_equal "friend@example.com", result.share.recipient_email
    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_equal [ "friend@example.com" ], ActionMailer::Base.deliveries.last.to
  end

  test "fails when post does not exist" do
    result = nil

    assert_no_difference("Share.count") do
      result = SharePost.new(
        post_id: -1,
        recipient_email: "friend@example.com",
        sender: users(:one)
      ).call
    end

    assert_not result.success?
    assert_includes result.errors, "Post not found"
    assert_equal 0, ActionMailer::Base.deliveries.count
  end

  test "fails when recipient email is invalid" do
    result = nil

    assert_no_difference("Share.count") do
      result = SharePost.new(
        post_id: posts(:one).id,
        recipient_email: "invalid-email",
        sender: users(:one)
      ).call
    end

    assert_not result.success?
    assert_includes result.errors, "Recipient email is invalid"
    assert_equal 0, ActionMailer::Base.deliveries.count
  end

  test "fails when same post is shared to same email twice" do
    Share.create!(post: posts(:one), user: users(:one), recipient_email: "friend@example.com")
    result = nil

    assert_no_difference("Share.count") do
      result = SharePost.new(
        post_id: posts(:one).id,
        recipient_email: "FRIEND@example.com",
        sender: users(:two)
      ).call
    end

    assert_not result.success?
    assert_includes result.errors, "This post was already shared with that email"
    assert_equal 0, ActionMailer::Base.deliveries.count
  end
end
