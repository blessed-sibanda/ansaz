# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  commentable_type :string           not null
#  content          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  commentable_id   :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_comments_on_commentable  (commentable_type,commentable_id)
#  index_comments_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class CommentTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:user)
    should belong_to(:commentable)
    should have_many(:comments)
  end

  context "validations" do
    should validate_presence_of(:content)
  end

  test "#parent_answer" do
    a = create(:answer)
    b = create(:comment, commentable: a)
    c = build(:comment, commentable: b)
    assert c.parent_answer == a
  end
end
