require "test_helper"

class DeliveryTest < ActiveSupport::TestCase
  test "prevents duplicate recipient per campaign" do
    campaign = Campaign.create!(user: users(:one), post: posts(:one), send_mode: :immediate)
    recipient = Recipient.create!(email: "dup@example.com")

    Delivery.create!(campaign: campaign, recipient: recipient)
    duplicate = Delivery.new(campaign: campaign, recipient: recipient)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:recipient_id], "has already been taken"
  end
end
