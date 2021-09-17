# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  about                  :text
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  name                   :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  context "associations" do
    should have_one_attached(:avatar)
    should have_many(:questions)
    should have_many(:answers)
    should have_many(:comments)
    should have_many(:stars)
    should have_many(:group_memberships)
    should have_many(:groups).through(:group_memberships).source(:group)
    should have_many(:active_groups)
             .through(:group_memberships)
             .source(:group)
    should have_many(:owned_groups)
             .class_name("Group")
             .with_foreign_key("admin_id")
  end

  test "#active returns confirmed users" do
    create_list :user, 4
    create_list :user, 7, :unconfirmed

    assert User.active.count == 4

    User.active.each do |u|
      refute u.confirmed_at.nil?
    end
  end

  test "#ranked orders users by # of questions & # of answers in ascending order of creation date" do
    u1 = create(:user)
    3.times { create(:question, user: u1) }
    3.times { create(:answer, user: u1) }

    u2 = create(:user)
    5.times { create(:question, user: u2) }
    3.times { create(:answer, user: u2) }

    u3 = create(:user)
    3.times { create(:question, user: u3) }
    3.times { create(:answer, user: u3) }

    u4 = create(:user)
    3.times { create(:question, user: u4) }
    4.times { create(:answer, user: u4) }

    assert User.ranked.first == u2
    assert User.ranked.second == u4
    assert User.ranked.third == u1
    assert User.ranked.fourth == u3
  end

  test "#starred returns the star of a given user if it exists" do
    u1 = create :user
    u2 = create :user
    q = create :question
    s = create :star, user: u1, starrable: q

    assert u1.starred(q) == s
    assert u2.starred(q).nil?
  end

  test "#unowned_groups returns groups in the user is not an admin but accepted" do
    u = create :user

    g1 = create :group, admin: u
    g2 = create :group
    g3 = create :group
    g4 = create :group

    create :group_membership, :accepted, user: u, group: g2
    create :group_membership, :pending, user: u, group: g3
    create :group_membership, :accepted, user: u, group: g4

    assert_not_includes u.unowned_groups, g1
    assert_includes u.unowned_groups, g2
    assert_not_includes u.unowned_groups, g3
    assert_includes u.unowned_groups, g4
  end

  test "#joined_on returns time which user joined the group" do
    u = create :user
    g = create :group
    gm = create :group_membership, :accepted, user: u, group: g
    assert_equal u.joined_on(g), gm.created_at.strftime("%d %b %Y")
  end

  test "#pending_approval shows whether user has pending group membership" do
    u = create :user
    g1 = create :group
    create :group_membership, :accepted, user: u, group: g1
    refute u.pending_approval(g1)

    g2 = create :group
    gm = create :group_membership, :pending, user: u, group: g2
    assert u.pending_approval(g2)
  end
end
