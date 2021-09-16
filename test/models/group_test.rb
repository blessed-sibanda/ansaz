# == Schema Information
#
# Table name: groups
#
#  id          :bigint           not null, primary key
#  description :text
#  group_type  :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  admin_id    :bigint
#
# Indexes
#
#  index_groups_on_name  (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_id => users.id)
#
require "test_helper"

class GroupTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:admin).class_name("User")
    should have_many(:group_memberships).dependent(:destroy)
    should have_many(:questions).dependent(:destroy)
    should have_many(:users)
             .through(:group_memberships)
             .source(:user)
    should have_many(:active_users)
             .through(:group_memberships)
             .source(:user)
  end

  context "validations" do
    should validate_presence_of(:name)
    should validate_presence_of(:description)
    should validate_presence_of(:banner)
    should validate_inclusion_of(:group_type)
             .in_array(Group::GROUP_TYPES)
    should have_one_attached(:banner)
    should validate_length_of(:name)
             .is_at_least(5)
             .is_at_most(30)
  end

  test "#active_users returns only accepted memberships" do
    g = create(:group)
    create_list(:group_membership, 10, group: g)
    g.active_users.each do |u|
      GroupMembership
        .find_by(user: u, group: g)
        .state == GroupMembership::ACCEPTED
    end
  end

  test "#ranked orders by # of questions & # of users" do
    g1 = create(:group)
    create_list :question, 3, group: g1
    create_list :group_membership, 2, group: g1

    g2 = create(:group)
    create_list :question, 5, group: g2
    create_list :group_membership, 6, group: g2

    g3 = create(:group)
    create_list :question, 3, group: g3
    create_list :group_membership, 3, group: g3

    assert Group.ranked.first == g2
    assert Group.ranked.second == g3
    assert Group.ranked.last == g1
  end

  test "#popular returns top 5 groups with most questions & users" do
    create_list :group, 11
    Group.all.each do |g|
      create_list :group_membership, rand(5..10), group: g
      create_list :question,
                  rand(5..10),
                  group: g,
                  user: g.active_users.sample
    end

    assert Group.popular.length == 5

    first = Group.popular.first
    second = Group.popular.second
    third = Group.popular.third
    fourth = Group.popular.fourth
    last = Group.popular.last

    assert first.questions.count + first.users.count \
             >= second.questions.count + second.users.count
    assert second.questions.count + second.users.count \
             >= third.questions.count + third.users.count
    assert third.questions.count + third.users.count \
             >= fourth.questions.count + fourth.users.count
    assert fourth.questions.count + fourth.users.count \
             >= last.questions.count + last.users.count
  end

  context "callbacks" do
    should callback(:add_admin_to_users).after(:create)
  end

  test "#add_admin_to_users" do
    admin = create :user
    g = create :group, admin: admin
    assert g.active_users.include?(admin)
  end
end
