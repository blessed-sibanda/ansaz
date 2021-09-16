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
class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group
  validates_uniqueness_of :user, scope: [:group_id]

  MEMBERSHIP_STATES = [
    PENDING = "Pending",
    ACCEPTED = "Accepted",
  ]

  validates :state, inclusion: { in: MEMBERSHIP_STATES }
  scope :pending, -> { where(state: PENDING) }
  scope :accepted, -> { where(state: ACCEPTED) }
end
