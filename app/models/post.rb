class Post < ApplicationRecord
  belongs_to :user, optional: true
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  has_rich_text :body
  has_one_attached :cover_image

  broadcasts_to ->(post) { "posts" }

  validates :title, presence: true
  validates :body, presence: true
  validate :cannot_edit_once_published

  def excerpt
    body.to_plain_text.truncate(160)
  end

  def reading_time
    words = body.to_plain_text.split.size
    [ words / 200, 1 ].max
  end

  private

  def cannot_edit_once_published
    if published? && changed? && !published_changed?
      errors.add(:base, "Published posts cannot be edited")
    end
  end
end
