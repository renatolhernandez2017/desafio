class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: {maximum: 1000}

  include PgSearch::Model

  pg_search_scope :search_full_text,
    against: :content,
    associated_against: {
      user: [:name]
    },
    using: {
      tsearch: {prefix: true}
    },
    ignoring: :accents
end
