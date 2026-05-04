require "test_helper"

class RetryFailedDeliveriesTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    clear_enqueued_jobs
    @campaign = Campaign.create!(user: users(:one), post: posts(:one), send_mode: :immediate)
    recipient = Recipient.create!(email: "retry@example.com")
    @delivery = Delivery.create!(
      campaign: @campaign,
      recipient: recipient,
      status: :failed,
      attempts_count: 1,
      next_retry_at: 1.minute.ago
    )
  end

  test "enqueues retry for eligible failed deliveries" do
    assert_enqueued_with(job: DeliveryJob, args: [ @delivery.id ]) do
      result = RetryFailedDeliveries.new(campaign: @campaign).call
      assert result.success?
      assert_equal 1, result.retried_count
    end
  end
end
