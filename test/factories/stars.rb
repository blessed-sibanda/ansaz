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
FactoryBot.define do
  factory :star do
    user { build(:user) }
    association :starrable,
                factory: [:question, :answer].sample,
                strategy: :build

    trait :question do
      association :starrable, factory: :question, strategy: :build
    end

    trait :answer do
      association :starrable, factory: :answer, strategy: :build
    end
  end
end
