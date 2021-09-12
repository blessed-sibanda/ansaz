# == Schema Information
#
# Table name: answers
#
#  id          :bigint           not null, primary key
#  accepted    :boolean          default(FALSE)
#  stars_count :bigint           default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_answers_on_question_id  (question_id)
#  index_answers_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (user_id => users.id)
#
class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question
  has_rich_text :content
  has_many :comments, as: :commentable
  has_many :stars, as: :starrable

  default_scope {
    order(accepted: :desc)
      .order(stars_count: :desc)
      .order(created_at: :desc)
  }

  after_create { QuestionMailer.answered(question).deliver_later }
end