require "application_system_test_case"

class PostActivityDashboardTest < ApplicationSystemTestCase
  test "user can search posts and open quick preview modal" do
    visit posts_path

    assert_text "Total posts"
    assert_text "Activity timeline"

    fill_in "Search title, content, or author", with: posts(:one).title
    assert_text posts(:one).title

    fill_in "Search title, content, or author", with: "zzzz-no-match"
    assert_text "No posts match your filters."

    click_button "Clear"
    assert_no_text "No posts match your filters."

    click_button "Quick preview", match: :first
    assert_selector "dialog[open]"
    assert_selector "turbo-frame#post_preview_modal", text: "Open full post"
  end
end
