require "test_helper"

class CampaignCreatorTest < ActiveSupport::TestCase
  test "creates campaign, deduplicates emails and creates pending deliveries" do
    result = CampaignCreator.new(
      user: users(:one),
      post: posts(:one),
      recipient_emails: "a@example.com, A@example.com\nb@example.com",
      send_mode: :immediate
    ).call

    assert result.success?
    assert_equal 2, result.recipient_count
    assert_equal 2, result.campaign.deliveries.pending.count
  end

  test "fails when recipient list includes invalid emails" do
    result = CampaignCreator.new(
      user: users(:one),
      post: posts(:one),
      recipient_emails: "good@example.com,invalid-email",
      send_mode: :immediate
    ).call

    assert_not result.success?
    assert_includes result.invalid_emails, "invalid-email"
  end
end
