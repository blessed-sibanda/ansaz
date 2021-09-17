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
#s
# Foreign Keys
#
#  fk_rails_...  (admin_id => users.id)
#
FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    description { Faker::Lorem.paragraphs.join }
    group_type { Group::GROUP_TYPES.sample }
    association :admin, factory: :user, strategy: :build

    after(:build) do |group|
      group.banner.attach(
        io: File.open(
          Rails.root.join("app",
                          "assets",
                          "images",
                          "default_banner_img.png")
        ),
        filename: "default_banner_img.png",
      )
    end

    trait :public do
      group_type { Group::PUBLIC }
    end

    trait :private do
      group_type { Group::PRIVATE }
    end
  end
end
