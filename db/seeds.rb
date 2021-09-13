# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(name: "Blessed Sibanda",
             email: "blessed@example.com",
             password: "1234pass",
             confirmed_at: Time.now,
             about: Faker::Lorem.paragraphs.join)

14.times do |i|
  User.create!(
    name: Faker::Name.name,
    email: "user-#{i}@example.com",
    password: "1234pass",
    confirmed_at: [Time.now, nil, nil].sample,
    about: Faker::Lorem.paragraphs.join,
  )
end

20.times do |i|
  Question.create!(
    user: User.active.sample,
    title: Faker::Lorem.sentence(word_count: rand(5..10)),
    content: Faker::Lorem.sentence(word_count: rand(75..150)),
  )
end

["Rails Devs", "Super Scientists", "Python Hackers", "Frontend Engineers", "Data Science Nerds"].each do |name|
  g = Group.new(
    name: name,
    description: Faker::Lorem.sentence(word_count: rand(50..80)),
    group_type: Group::GROUP_TYPES.sample,
    admin: User.active.sample,
  )
  g.banner.attach(
    io: File.open(Rails.root.join("app", "assets", "images", "default_banner_img.png")),
    filename: "default_banner_img.png",
  )
  g.save!
end

["JavaScript", "Programming", "Ruby-on-Rails", "Science"].each do |name|
  Tag.create!(name: name)
end
