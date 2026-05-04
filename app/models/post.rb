class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :shares, dependent: :destroy
  has_many :campaigns, dependent: :destroy

  validates :title, :body, presence: true

  def title_with_author
    name = user&.name.presence || "User ##{user_id}"
    "#{title} (#{name})"
  end
end
