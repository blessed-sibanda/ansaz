class RemoveStarsCountFromQuestionsAndAnswers < ActiveRecord::Migration[6.1]
  def change
    remove_column :questions, :stars_count
    remove_column :answers, :stars_count
  end
end
