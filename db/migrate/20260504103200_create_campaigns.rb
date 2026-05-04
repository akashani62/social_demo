class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.integer :send_mode, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :scheduled_at
      t.datetime :processed_at

      t.timestamps
    end

    add_index :campaigns, :status
    add_index :campaigns, :scheduled_at
  end
end
