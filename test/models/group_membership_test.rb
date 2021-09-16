# == Schema Information
#
# Table name: group_memberships
#
#  id         :bigint           not null, primary key
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_group_memberships_on_group_id              (group_id)
#  index_group_memberships_on_user_id               (user_id)
#  index_group_memberships_on_user_id_and_group_id  (user_id,group_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class GroupMembershipTest < ActiveSupport::TestCase
  subject { build(:group_membership) }

  context "associations" do
    should belong_to(:user)
    should belong_to(:group)
  end

  context "validations" do
    should validate_uniqueness_of(:user).scoped_to(:group_id)
    should validate_inclusion_of(:state)
             .in_array(GroupMembership::MEMBERSHIP_STATES)
  end

  test "#pending only returns pending memberships" do
    create_list :group_membership, 10
    GroupMembership.pending.each do |gm|
      assert gm.state == GroupMembership::PENDING
    end
  end

  test "#accepted only returns accepted memberships" do
    create_list :group_membership, 10
    GroupMembership.accepted.each do |gm|
      assert gm.state == GroupMembership::ACCEPTED
    end
  end
end
