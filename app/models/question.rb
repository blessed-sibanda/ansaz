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
  scope :ungrouped, -> { where(group_id: nil) }
end
