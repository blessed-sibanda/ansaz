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
class Star < ApplicationRecord
  belongs_to :user
  belongs_to :starrable, polymorphic: true
  validates_uniqueness_of :user, scope: [:starrable_id,
                                         :starrable_type]

  after_save :update_stars_count
  after_destroy :update_stars_count

  def update_stars_count
    starrable.stars_count = starrable.stars.count
    starrable.save!
  end
end
