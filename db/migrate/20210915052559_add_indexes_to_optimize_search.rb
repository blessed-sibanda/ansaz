class AddIndexesToOptimizeSearch < ActiveRecord::Migration[6.1]
  def change
    add_index :questions, "title varchar_pattern_ops"
    add_index :action_text_rich_texts, "body text_pattern_ops"
  end
end
