require "test_helper"

class RecipientTest < ActiveSupport::TestCase
  test "normalizes email before validation" do
    recipient = Recipient.create!(email: "  TEST@Example.COM ")

    assert_equal "test@example.com", recipient.email
  end

  test "rejects invalid email" do
    recipient = Recipient.new(email: "bad-email")

    assert_not recipient.valid?
    assert_includes recipient.errors[:email], "is invalid"
  end
end
