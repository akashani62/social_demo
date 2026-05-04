class CreateShares < ActiveRecord::Migration[8.1]
  def change
    create_table :shares do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :recipient_email, null: false

      t.timestamps
    end

    add_index :shares, [ :post_id, :recipient_email ], unique: true
  end
end
