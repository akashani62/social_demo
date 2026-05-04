class Delivery < ApplicationRecord
  belongs_to :campaign
  belongs_to :recipient

  enum :status, { pending: 0, sent: 1, failed: 2 }

  validates :status, presence: true
  validates :recipient_id, uniqueness: { scope: :campaign_id }
end
