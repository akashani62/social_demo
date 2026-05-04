require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  test "scheduled campaigns require scheduled_at" do
    campaign = Campaign.new(user: users(:one), post: posts(:one), send_mode: :scheduled)

    assert_not campaign.valid?
    assert_includes campaign.errors[:scheduled_at], "can't be blank"
  end

  test "immediate campaigns are valid without scheduled_at" do
    campaign = Campaign.new(user: users(:one), post: posts(:one), send_mode: :immediate)

    assert campaign.valid?
  end
end
