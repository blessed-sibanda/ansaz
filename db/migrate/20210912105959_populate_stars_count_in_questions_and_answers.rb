class PopulateStarsCountInQuestionsAndAnswers < ActiveRecord::Migration[6.1]
  def up
    Question.all.each do |question|
      question.stars_count = question.stars.count
      question.answers.each do |answer|
        answer.stars_count = answer.stars.count
        answer.save!
      end
      question.save!
    end
  end

  def down
    Question.all.each do |question|
      question.answers.each do |answer|
        answer.stars_count = 0
        answer.save!
      end
      question.stars_count = 0
      question.save!
    end
  end
end
