require "test_helper"

class DeliveryProcessorTest < ActiveSupport::TestCase
  setup do
    campaign = Campaign.create!(user: users(:one), post: posts(:one), send_mode: :immediate)
    recipient = Recipient.create!(email: "receiver@example.com")
    @delivery = Delivery.create!(campaign: campaign, recipient: recipient, status: :pending)
  end

  test "marks delivery as sent when mail succeeds" do
    result = DeliveryProcessor.new(delivery: @delivery).call

    assert result.success?
    assert_equal "sent", @delivery.reload.status
    assert @delivery.sent_at.present?
    assert @delivery.attempts_count.positive?
  end
end
