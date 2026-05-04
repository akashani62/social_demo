require "test_helper"

class DeliveryJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  setup do
    clear_enqueued_jobs
    campaign = Campaign.create!(user: users(:one), post: posts(:one), send_mode: :immediate)
    recipient = Recipient.create!(email: "job@example.com")
    @delivery = Delivery.create!(campaign: campaign, recipient: recipient, status: :pending)
  end

  test "processes a delivery and marks it sent" do
    DeliveryJob.perform_now(@delivery.id)

    assert_equal "sent", @delivery.reload.status
    assert_equal "completed", @delivery.campaign.reload.status
    assert @delivery.campaign.processed_at.present?
  end
end
