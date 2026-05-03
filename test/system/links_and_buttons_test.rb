require "application_system_test_case"

class LinksAndButtonsTest < ApplicationSystemTestCase
  include ActionView::RecordIdentifier

  setup do
    @alice = users(:one)
    @bob = users(:two)
    @post = posts(:one)
  end

  # --- Navigation (layout) ---
  test "header links navigate to posts, comments, users, and home" do
    visit root_path

    click_on "Comments"
    assert_current_path comments_path
    assert_selector "h1", text: "Comments"

    click_on "Users"
    assert_current_path users_path
    assert_selector "h1", text: "Users"

    click_on "Posts"
    assert_current_path posts_path
    assert_selector "h1", text: "Posts"

    click_on "Social Demo"
    assert_current_path root_path
  end

  test "guest can open sign in from nav" do
    visit posts_path
    click_on "Sign in"
    assert_current_path sign_in_path
    assert_selector "h1", text: "Sign in"
  end

  test "guest sees sign in to post on posts index" do
    visit posts_path
    click_on "Sign in to post"
    assert_current_path sign_in_path
  end

  # --- Auth ---
  test "sign in and sign out buttons work" do
    visit posts_path
    click_on "Sign in"
    fill_in "Email", with: @alice.email
    fill_in "Password", with: SessionTestHelper::FIXTURE_USER_PASSWORD
    click_button "Sign in"

    assert_current_path root_path
    click_on "Sign out"
    assert_current_path root_path
    assert_selector "a", text: "Sign in"
  end

  # --- Posts: modal create ---
  test "new post button opens modal and form submits without full page navigation" do
    sign_in_via_browser(@alice)
    visit posts_path

    click_button "New post"
    assert_selector "dialog[open]", wait: 10
    within "dialog" do
      assert_selector "turbo-frame#new_post_modal", wait: 10
      assert_field "Title"
      assert_field "Body"
      fill_in "Title", with: "System test post"
      fill_in "Body", with: "Body from system test"
      click_button "Create Post"
    end

    assert_no_selector "dialog[open]", wait: 10
    assert_text "System test post"
  end

  test "new post modal close control dismisses dialog" do
    sign_in_via_browser(@alice)
    visit posts_path

    click_button "New post"
    assert_selector "dialog[open]", wait: 10
    within "dialog" do
      find("button[aria-label='Close']").click
    end
    assert_no_selector "dialog[open]", wait: 5
  end

  # --- Posts: row actions ---
  test "post row open link loads full post page" do
    visit posts_path
    click_on "Open", match: :first
    assert_current_path post_path(@post)
    assert_selector "h1", text: @post.title
  end

  test "owner can open inline edit from post row" do
    sign_in_via_browser(@alice)
    visit posts_path

    within %(turbo-frame##{dom_id(@post)}) do
      click_on "Edit"
    end
    within %(turbo-frame##{dom_id(@post)}) do
      assert_field "Title", with: @post.title
      click_on "Cancel"
    end
    within %(turbo-frame##{dom_id(@post)}) do
      assert_text @post.title
      assert_link "Edit"
    end
  end

  # --- Post show: comments modal ---
  test "add comment button opens modal and creates comment" do
    sign_in_via_browser(@bob)
    visit post_path(@post)

    click_button "Add comment"
    assert_selector "dialog[open]", wait: 10
    within "dialog" do
      assert_selector "turbo-frame#new_comment_modal", wait: 10
      fill_in "Body", with: "Comment from system test"
      click_button "Create Comment"
    end

    assert_no_selector "dialog[open]", wait: 10
    assert_text "Comment from system test"
  end

  test "guest sees sign in to comment on post page" do
    visit post_path(@post)
    click_on "Sign in to comment"
    assert_current_path sign_in_path
  end

  test "back to posts link from post show" do
    visit post_path(@post)
    click_on "← Back to posts"
    assert_current_path posts_path
  end

  # --- Users CRUD entry points ---
  test "users index new user link" do
    visit users_path
    click_on "New user"
    assert_current_path new_user_path
    assert_selector "h1", text: "New user"
  end

  # --- Comments index ---
  test "comments index new comment link for signed in user" do
    sign_in_via_browser(@alice)
    visit comments_path
    click_on "New comment"
    assert_current_path new_comment_path
  end
end
