require "application_system_test_case"

class CampaignsFlowTest < ApplicationSystemTestCase
  test "user creates campaign and sees sent status updates" do
    sign_in_via_browser(users(:one))
    visit post_path(posts(:one))
    click_link "Create sharing campaign"

    select posts(:one).title, from: "Post"
    fill_in "Recipient emails", with: "first@example.com\nsecond@example.com"
    select "Immediate", from: "Send mode"

    perform_enqueued_jobs do
      click_button "Create campaign"
    end

    assert_text "Campaign created successfully."
    assert_text "Post sharing campaign"
    assert_text "Sent"
    assert_text "2"
  end
end
