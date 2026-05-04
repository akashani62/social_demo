class Share < ApplicationRecord
  EMAIL_FORMAT = URI::MailTo::EMAIL_REGEXP

  belongs_to :post
  belongs_to :user

  before_validation :normalize_recipient_email

  validates :post, :user, presence: true
  validates :recipient_email, presence: true, format: { with: EMAIL_FORMAT }
  validates :recipient_email, uniqueness: {
    scope: :post_id,
    case_sensitive: false,
    message: "has already received this post"
  }

  private

    def normalize_recipient_email
      self.recipient_email = recipient_email.to_s.strip.downcase
    end
end
