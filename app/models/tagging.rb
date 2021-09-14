# == Schema Information
#
# Table name: taggings
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :bigint           not null
#  tag_id      :bigint           not null
#
# Indexes
#
#  index_taggings_on_question_id  (question_id)
#  index_taggings_on_tag_id       (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (tag_id => tags.id)
#
class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :question

  validates_uniqueness_of :tag_id, scope: [:question_id]
end
