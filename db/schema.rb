# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_04_103400) do
  create_table "campaigns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "post_id", null: false
    t.datetime "processed_at"
    t.datetime "scheduled_at"
    t.integer "send_mode", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["post_id"], name: "index_campaigns_on_post_id"
    t.index ["scheduled_at"], name: "index_campaigns_on_scheduled_at"
    t.index ["status"], name: "index_campaigns_on_status"
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "post_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "deliveries", force: :cascade do |t|
    t.integer "attempts_count", default: 0, null: false
    t.integer "campaign_id", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.datetime "last_attempt_at"
    t.datetime "next_retry_at"
    t.integer "recipient_id", null: false
    t.datetime "sent_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "recipient_id"], name: "index_deliveries_on_campaign_id_and_recipient_id", unique: true
    t.index ["campaign_id"], name: "index_deliveries_on_campaign_id"
    t.index ["next_retry_at"], name: "index_deliveries_on_next_retry_at"
    t.index ["recipient_id"], name: "index_deliveries_on_recipient_id"
    t.index ["status"], name: "index_deliveries_on_status"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "recipients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_recipients_on_email", unique: true
  end

  create_table "shares", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "post_id", null: false
    t.string "recipient_email", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["post_id", "recipient_email"], name: "index_shares_on_post_id_and_recipient_email", unique: true
    t.index ["post_id"], name: "index_shares_on_post_id"
    t.index ["user_id"], name: "index_shares_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "campaigns", "posts"
  add_foreign_key "campaigns", "users"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "deliveries", "campaigns"
  add_foreign_key "deliveries", "recipients"
  add_foreign_key "posts", "users"
  add_foreign_key "shares", "posts"
  add_foreign_key "shares", "users"
end
