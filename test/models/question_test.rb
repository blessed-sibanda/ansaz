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
require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:title)
  end

  should have_rich_text(:content)

  context "associations" do
    should belong_to(:user)
    should belong_to(:group).optional
    should have_many(:stars)
    should have_many(:answers)
    should have_many(:tags)
  end

  test "#ungrouped returns questions without groups" do
    create_list :question, 3, :grouped
    assert Question.ungrouped.count == 0

    create_list :question, 4
    assert Question.ungrouped.count == 4

    Question.ungrouped.each do |q|
      assert q.group.nil?
    end
  end

  test "#popular orders questions by # of stars & # of answers" do
    create_list :question, 15
    Question.all.each do |q|
      create_list :answer, rand(3..10), question: q
      create_list :star, rand(3..10), starrable: q
    end
    assert_equal Question.popular.length, 10

    first = Question.popular.first
    second = Question.popular.first
    third = Question.popular.third
    fourth = Question.popular.fourth
    last = Question.popular.last

    assert first.answers.count + first.stars.count \
             >= second.answers.count + second.stars.count
    assert second.answers.count + second.stars.count \
             >= third.answers.count + third.stars.count
    assert third.answers.count + third.stars.count \
             >= fourth.answers.count + fourth.stars.count
    assert fourth.answers.count + fourth.stars.count \
             >= last.answers.count + last.stars.count
  end

  test "#similar returns questions with similar tags" do
    q1 = create :question
    q1.tag_list = "people,love,food"
    q1.save!

    q2 = create :question
    q2.tag_list = "love,life,people"
    q2.save!

    q3 = create :question
    q3.tag_list = "food,love,chocolate"
    q3.save!

    assert_equal q1.similar(5).length, 2
    assert q1.similar(5).include?(q2)
    assert q1.similar(5).include?(q3)
  end
end
