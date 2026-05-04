class Recipient < ApplicationRecord
  EMAIL_FORMAT = URI::MailTo::EMAIL_REGEXP

  has_many :deliveries, dependent: :destroy
  has_many :campaigns, through: :deliveries

  before_validation :normalize_email

  validates :email, presence: true, format: { with: EMAIL_FORMAT }, uniqueness: { case_sensitive: false }

  private

    def normalize_email
      self.email = email.to_s.strip.downcase
    end
end
