# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#
class Tag < ApplicationRecord
  has_many :taggings
  has_many :questions, through: :taggings
  after_save { name.downcase! }

  include PgSearch::Model
  multisearchable against: [:name]
end
