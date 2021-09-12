class AddStarsCountToAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :answers, :stars_count, :bigint, default: 0
  end
end
