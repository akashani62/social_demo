require "test_helper"

class ShareTest < ActiveSupport::TestCase
  setup do
    @share = Share.new(
      post: posts(:one),
      user: users(:one),
      recipient_email: "friend@example.com"
    )
  end

  test "is valid with valid attributes" do
    assert @share.valid?
  end

  test "requires recipient email" do
    @share.recipient_email = ""

    assert_not @share.valid?
    assert_includes @share.errors[:recipient_email], "can't be blank"
  end

  test "requires valid recipient email format" do
    @share.recipient_email = "not-an-email"

    assert_not @share.valid?
    assert_includes @share.errors[:recipient_email], "is invalid"
  end

  test "normalizes recipient email before validation" do
    @share.recipient_email = "  Friend@Example.COM "
    @share.valid?

    assert_equal "friend@example.com", @share.recipient_email
  end

  test "prevents duplicate share for the same post and recipient email" do
    Share.create!(post: posts(:one), user: users(:one), recipient_email: "friend@example.com")
    duplicate = Share.new(post: posts(:one), user: users(:two), recipient_email: "FRIEND@example.com")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:recipient_email], "has already received this post"
  end
end
