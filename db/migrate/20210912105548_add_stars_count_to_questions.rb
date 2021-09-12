class AddStarsCountToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :questions, :stars_count, :bigint, default: 0
  end
end
