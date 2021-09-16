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
require "test_helper"

class AnswerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  context "associations" do
    should belong_to(:user)
    should belong_to(:question)
    should have_many(:comments)
    should have_many(:stars)
  end

  should have_rich_text(:content)

  test "#ranked orders by accepted status & # of stars" do
    q = create(:question)
    a1 = create(:answer, question: q)
    3.times { create(:star, starrable: a1) }
    a2 = create(:answer, :accepted, question: q)
    create(:star, starrable: a1)
    a3 = create(:answer, question: q)

    assert q.answers.ranked.first == a2
    assert q.answers.ranked.second == a1
    assert q.answers.ranked.last == a3
  end

  test "answering a question sends email to question owner" do
    q = create(:question)

    assert_changes("ActionMailer::Base.deliveries.size",
                   from: 0, to: 1) do
      perform_enqueued_jobs do
        create :answer, question: q
      end
    end

    email = ActionMailer::Base.deliveries.last
    assert email.subject == "Answered"
    assert email.to == [q.user.email]
  end

  test "#parent_answer returns self" do
    a = build(:answer)
    assert a.parent_answer == a
  end
end
