User.create!(name: "Blessed Sibanda",
             email: "blessed@example.com",
             password: "1234pass",
             confirmed_at: Time.now,
             about: Faker::Lorem.paragraphs.join)

100.times do |i|
  User.create!(
    name: Faker::Name.name,
    email: "user-#{i}@example.com",
    password: "1234pass",
    confirmed_at: [Time.now, Time.now, Time.now, nil].sample, # 75% of users are activated
    about: Faker::Lorem.paragraphs.join,
  )
end

puts "Adding groups"
30.times do
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

  rand(15..30).times do
    gm = GroupMembership.new(
      user: User.active.sample,
      group: g,
      state: GroupMembership::MEMBERSHIP_STATES.sample,
    )
    gm.save
  end
end

puts "Adding questions"
500.times do |i|
  include FactoryBot::Syntax::Methods
  q = create :question
  tags = []
  rand(1..3).times.each do
    tags << Faker::Educator.subject.downcase.gsub(/[^A-Za-z-]/, "")
  end

  q.tag_list = tags.uniq
  q.save!

  if i % 5 == 0 # one in 5 questions belongs to a group
    q.group = Group.all.sample
    q.save
  end

  rand(5..10).times do
    Answer.create!(
      question: q,
      content: Faker::Lorem.paragraphs.join,
      accepted: rand(1..10) == 1,
      user: q.group ? q.group.active_users.sample : User.active.sample,
    )
  end

  print(".") if i % 100 == 0
end

puts "Adding stars"
5_000.times do |i|
  star = Star.new(
    user: User.active.sample,
    starrable: [Question.all.sample, Answer.all.sample].sample,
  )
  star.save! if star.valid?
  print(".") if i % 100 == 0
end

puts "Adding comments"
5_000.times do |i|
  comment = Comment.new(
    user: User.active.sample,
    commentable: [Answer.all.sample, Comment.all.sample].sample,
    content: Faker::Lorem.paragraphs(number: rand(1..4)).join,
  )
  comment.save! if comment.valid?
  print(".") if i % 100 == 0
end
