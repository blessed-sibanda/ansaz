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
FactoryBot.define do
  factory :tag do
    name { Faker::Educator.subject.gsub(/[^A-Za-z-]/, "") }
  end
end
