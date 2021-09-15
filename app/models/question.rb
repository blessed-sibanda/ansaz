# == Schema Information
#
# Table name: questions
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :bigint
#  user_id    :bigint           not null
#
# Indexes
#
#  index_questions_on_group_id  (group_id)
#  index_questions_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (user_id => users.id)
#
class Question < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search,
                  against: :title,
                  associated_against: {
                    rich_text_content: [:body],
                    tags: [:name],
                  }

  belongs_to :user
  has_many :answers
  has_many :stars, as: :starrable
  belongs_to :group, optional: true

  validates :title, presence: true

  scope :paginated, ->(page, group: nil) {
      where(group: group&.id)
        .order(created_at: :desc)
        .paginate(page: page, per_page: 10)
    }

  has_many :taggings
  has_many :tags, through: :taggings

  has_rich_text :content

  def self.tagged_with(name)
    Tag.find_by(name: name).questions
  end

  def tag_list
    tags.map(&:name)
  end

  def tag_list=(names)
    self.tags = names.split(",").map do |n|
      Tag.where(name: n.strip).first_or_create! unless n.blank?
    end
  end
end
