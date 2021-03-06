# == Schema Information
#
# Table name: answers
#
#  id          :bigint           not null, primary key
#  accepted    :boolean          default(FALSE)
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

  scope :ranked, -> {
          left_joins(:stars).group(:id)
                            .order(accepted: :desc)
                            .order("COUNT(stars.id) DESC")
                            .order(created_at: :asc)
        }

  after_create :email_question_asker

  def parent_answer
    self
  end

  def email_question_asker
    QuestionMailer.answered(question).deliver_later
  end
end
