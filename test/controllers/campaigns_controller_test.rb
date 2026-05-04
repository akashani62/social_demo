require "test_helper"

class CampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:one)
  end

  test "guest cannot access new" do
    get new_campaign_url
    assert_redirected_to sign_in_url
  end

  test "signed in user can open new campaign form" do
    sign_in_as(@user)
    get new_campaign_url(post_id: @post.id)

    assert_response :success
    assert_match "Create sharing campaign", response.body
  end

  test "signed in user creates immediate campaign" do
    sign_in_as(@user)

    assert_difference("Campaign.count", 1) do
      post campaigns_url, params: {
        campaign: {
          post_id: @post.id,
          recipient_emails: "c1@example.com,c2@example.com",
          send_mode: "immediate"
        }
      }
    end

    assert_redirected_to campaign_url(Campaign.last)
  end

  test "show only allows campaign owner" do
    other_campaign = Campaign.create!(user: users(:two), post: posts(:two), send_mode: :immediate)
    sign_in_as(@user)

    assert_raises(ActiveRecord::RecordNotFound) do
      get campaign_url(other_campaign)
    end
  end
end
