require "test_helper"

class RetryFailedDeliveriesJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  setup do
    clear_enqueued_jobs
    @campaign = Campaign.create!(user: users(:one), post: posts(:one), send_mode: :immediate)
    recipient = Recipient.create!(email: "retryjob@example.com")
    @delivery = Delivery.create!(
      campaign: @campaign,
      recipient: recipient,
      status: :failed,
      attempts_count: 1,
      next_retry_at: 1.minute.ago
    )
  end

  test "enqueues delivery retries" do
    assert_enqueued_with(job: DeliveryJob, args: [ @delivery.id ]) do
      RetryFailedDeliveriesJob.perform_now(@campaign.id)
    end
  end
end
