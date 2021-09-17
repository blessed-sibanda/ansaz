# == Schema Information
#
# Table name: questions
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :bigint
#  user_id    :bigint           not null
#
# Indexes
#
#  index_questions_on_group_id  (group_id)
#  index_questions_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :question do
    title { ["What is", "Why", "Who", "Where", "How"].sample + " " + Faker::Lorem.sentence.downcase + " #{SecureRandom.hex(2)}" }
    user { build(:user) }
    content { Faker::Lorem.paragraphs(number: 7).join }

    trait :grouped do
      association :group, strategy: :build
    end
  end
end
