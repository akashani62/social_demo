require "test_helper"

class CampaignSchedulerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    clear_enqueued_jobs
    @campaign = Campaign.create!(user: users(:one), post: posts(:one), send_mode: :immediate)
  end

  test "enqueues execution immediately for immediate campaign" do
    assert_enqueued_with(job: CampaignExecutionJob, args: [ @campaign.id ]) do
      result = CampaignScheduler.new(campaign: @campaign).call
      assert result.success?
    end
  end

  test "enqueues execution for future time when scheduled" do
    scheduled_campaign = Campaign.create!(
      user: users(:one),
      post: posts(:one),
      send_mode: :scheduled,
      scheduled_at: 2.hours.from_now
    )

    assert_enqueued_with(job: CampaignExecutionJob, args: [ scheduled_campaign.id ]) do
      result = CampaignScheduler.new(campaign: scheduled_campaign).call
      assert result.success?
    end
  end
end
