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
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  has_one_attached :avatar

  scope :active, -> { where.not(confirmed_at: nil) }

  has_many :questions
  has_many :answers
  has_many :comments
  has_many :stars

  has_many :owned_groups, class_name: "Group",
                          foreign_key: "admin_id"
  has_many :group_memberships
  has_many :groups, through: :group_memberships, source: :group

  def starred(starrable)
    Star.where(user: self, starrable: starrable).first
  end

  def joined_on(group)
    group_memberships.where(group: group).
      first&.created_at.strftime("%d %b %Y")
  end

  def pending_approval(group)
    group_memberships.where(
      group: group,
      state: GroupMembership::PENDING,
    ).any?
  end
end
