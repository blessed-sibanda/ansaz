# == Schema Information
#
# Table name: questions
#
#  id          :bigint           not null, primary key
#  stars_count :bigint           default(0)
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  group_id    :bigint
#  user_id     :bigint           not null
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
  belongs_to :user
  has_rich_text :content
  has_many :answers
  has_many :stars, as: :starrable
  belongs_to :group, optional: true

  validates :title, presence: true

  scope :ungrouped, -> { where(group_id: nil) }

  has_many :taggings
  has_many :tags, through: :taggings

  def self.tagged_with(name)
    Tag.find_by(name: name).questions
  end

  def self.tag_counts
    Tag.select("tags.*, count(taggings.tag_id) as count").joins
    (:taggings).group("taggings.tag_id")
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
