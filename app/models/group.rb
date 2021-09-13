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
class Group < ApplicationRecord
  after_create :add_admin_to_users
  belongs_to :admin, class_name: "User", foreign_key: "admin_id"
  has_one_attached :banner

  GROUP_TYPES = [
    PUBLIC = "Public",
    PRIVATE = "Private",
  ].freeze

  validates :name, :description, :banner, presence: true
  validates :name, length: { in: 5..30 }
  validates :group_type, inclusion: { in: GROUP_TYPES }

  has_many :group_memberships
  has_many :users, through: :group_memberships, source: :user

  def add_admin_to_users
    GroupMembership::Creator.call(user: admin, group: self)
  end
end
