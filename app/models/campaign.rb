class Campaign < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :deliveries, dependent: :destroy
  has_many :recipients, through: :deliveries

  enum :send_mode, { immediate: 0, scheduled: 1 }
  enum :status, { pending: 0, running: 1, completed: 2, completed_with_failures: 3 }

  validates :send_mode, :status, presence: true
  validates :scheduled_at, presence: true, if: :scheduled?
end
