# == Schema Information
#
# Table name: stars
#
#  id             :bigint           not null, primary key
#  starrable_type :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  starrable_id   :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_stars_on_starrable  (starrable_type,starrable_id)
#  index_stars_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class StarTest < ActiveSupport::TestCase
  subject { build(:star) }

  context "associations" do
    should belong_to(:user)
    should belong_to(:starrable)
  end

  context "validations" do
    should validate_uniqueness_of(:user)
             .scoped_to([:starrable_id, :starrable_type])
  end
end
