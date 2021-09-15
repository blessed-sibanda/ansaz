User.create!(name: "Blessed Sibanda",
             email: "blessed@example.com",
             password: "1234pass",
             confirmed_at: Time.now,
             about: Faker::Lorem.paragraphs.join)

1000.times do |i|
  User.create!(
    name: Faker::Name.name,
    email: "user-#{i}@example.com",
    password: "1234pass",
    confirmed_at: [Time.now, nil, nil].sample,
    about: Faker::Lorem.paragraphs.join,
  )
end

40.times do
  name = Faker::Book.genre
  unless Group.find_by_name(name)
    g = Group.new(
      name: name,
      admin: User.active.sample,
      group_type: Group::GROUP_TYPES.sample,
      description: Faker::Lorem.sentence(word_count: rand(50..80)),
    )
    g.banner.attach(
      io: File.open(Rails.root.join("app", "assets", "images", "default_banner_img.png")),
      filename: "default_banner_img.png",
    )
    g.save!
  end
end

2_000.times do |i|
  include FactoryBot::Syntax::Methods
  q = create :question
  tags = []
  rand(1..3).times.each do
    tags << Faker::Educator.subject.downcase.gsub(/[^A-Za-z-]/, "")
  end

  q.tag_list = tags.uniq.join(",")

  if i % 5 == 0 # one in 5 questions belongs to a group
    q.group = Group.all.sample
    q.save
  end

  if i % 100 == 0
    print(".")
  end
end
