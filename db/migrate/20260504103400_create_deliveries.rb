class CreateDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :deliveries do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :recipient, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :sent_at
      t.text :error_message
      t.integer :attempts_count, null: false, default: 0
      t.datetime :last_attempt_at
      t.datetime :next_retry_at

      t.timestamps
    end

    add_index :deliveries, [ :campaign_id, :recipient_id ], unique: true
    add_index :deliveries, :status
    add_index :deliveries, :next_retry_at
  end
end
