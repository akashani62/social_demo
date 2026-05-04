require "test_helper"

class CampaignExecutionJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  setup do
    clear_enqueued_jobs
    @campaign = Campaign.create!(user: users(:one), post: posts(:one), send_mode: :immediate)
    recipient_a = Recipient.create!(email: "ja@example.com")
    recipient_b = Recipient.create!(email: "jb@example.com")
    Delivery.create!(campaign: @campaign, recipient: recipient_a, status: :pending)
    Delivery.create!(campaign: @campaign, recipient: recipient_b, status: :pending)
  end

  test "marks campaign running and enqueues delivery jobs" do
    assert_enqueued_jobs 2, only: DeliveryJob do
      CampaignExecutionJob.perform_now(@campaign.id)
    end

    assert_equal "running", @campaign.reload.status
  end

  test "marks campaign completed when no deliveries remain" do
    @campaign.deliveries.delete_all

    CampaignExecutionJob.perform_now(@campaign.id)

    assert_equal "completed", @campaign.reload.status
    assert @campaign.processed_at.present?
  end
end
