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
    name { "MyString" }
    description { }
    admin_id { "" }
    group_type { "MyString" }
  end
end
