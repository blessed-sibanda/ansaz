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
FactoryBot.define do
  factory :group_membership do
    user
    group
    state { GroupMembership::MEMBERSHIP_STATES.sample }

    trait :accepted do
      state { GroupMembership::ACCEPTED }
    end

    trait :pending do
      state { GroupMembership::PENDING }
    end
  end
end
