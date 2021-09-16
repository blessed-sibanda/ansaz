# 10 Testing

In this chapter we are going to write test code to always ensure that our application works as expected.

## 10.1 Testing Models

We are going to unit test our models using `shoulda-matchers` gem. This gem makes testing the functionality of our activerecord models a breeze.

Lets install `shoulda-matchers` and `shoulda-context`

```
$ bundle add shoulda-matchers --group=test
$ bundle add shoulda-context --group=test
```

Include `shoulda-matchers` in `test/test_helper.rb` and also factory bot syntax methods to the `ActiveSupport::TestCase` class.

```ruby
class ActiveSupport::TestCase
  ...
  ...

  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
```

Before writing tests for our models, lets first update our data factories in `test/factories` directory so that we can easily create test data.

Update `test/factories/answers.rb`

```ruby
FactoryBot.define do
  factory :answer do
    user { build(:user) }
    question { build(:question) }
    accepted { false }

    trait :accepted do
      accepted { true }
    end
  end
end
```

Note that we added a `:accepted` trait to create accepted answers.

Update `test/factories/users.rb`

```ruby
FactoryBot.define do
  factory :user do
    email { "user-#{SecureRandom.hex(3)}@example.com" }
    name { Faker::Name.name }
    confirmed_at { Time.zone.now }
    password { "1234pass" }
    about { Faker::Lorem.paragraphs.join }
  end
end
```

Update `test/factories/questions.rb`

```ruby
FactoryBot.define do
  factory :question do
    title { ["What is", "Why", "Who", "Where", "How"].sample + " " + Faker::Lorem.sentence.downcase + " #{SecureRandom.hex(2)}" }
    user { build(:user) }
    content { Faker::Lorem.paragraphs(number: 7).join }
  end
end
```

Update `test/factories/stars.rb`

```ruby
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
```

Now lets add tests to the answer model

```ruby
class AnswerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  context "associations" do
    should belong_to(:user)
    should belong_to(:question)
    should have_many(:comments)
    should have_many(:stars)
  end

  should have_rich_text(:content)

  test "#ranked orders by accepted status & # of stars" do
    q = create(:question)
    a1 = create(:answer, question: q)
    3.times { create(:star, starrable: a1) }
    a2 = create(:answer, :accepted, question: q)
    create(:star, starrable: a1)
    a3 = create(:answer, question: q)

    assert q.answers.ranked.first == a2
    assert q.answers.ranked.second == a1
    assert q.answers.ranked.last == a3
  end

  test "answering a question sends email to question owner" do
    q = create(:question)

    assert_changes("ActionMailer::Base.deliveries.size",
                   from: 0, to: 1) do
      perform_enqueued_jobs do
        create :answer, question: q
      end
    end

    email = ActionMailer::Base.deliveries.last
    assert email.subject == "Answered"
    assert email.to == [q.user.email]
  end

  test "#parent_answer returns self" do
    a = build(:answer)
    assert a.parent_answer == a
  end
end
```

```
$ rails test test/models/answer_test.rb
```

The test code is generally straightforward, we are using the `shoulda-matchers` helper methods to test the associations of `answer` with other models. We are also testing that an email is delivered to the question's asker whenever a new answer is created. It is also important to note that we are `perfom`ing `enqueued_jobs` before creating an answer because the email is 'delivered later' (i.e its delivered in a background job). We also check that the `Answer#parent_answer` returns the answer object itself.

Now lets test the `comment` model

First lets update `test/factories/comments.rb`

```ruby
FactoryBot.define do
  factory :comment do
    user { build(:user) }
    commentable { [build(:answer), build(:comment)].sample }
    content { Faker::Lorem.paragraphs.join }
  end
end
```

Then lets update the `comment_test.rb` itself

```ruby
class CommentTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:user)
    should belong_to(:commentable)
    should have_many(:comments)
  end

  context "validations" do
    should validate_presence_of(:content)
  end

  test "#parent_answer" do
    a = create(:answer)
    b = create(:comment, commentable: a)
    c = build(:comment, commentable: b)
    assert c.parent_answer == a
  end
end
```

```
$ rails test test/models/comment_test.rb
```

Now lets test the group-membership model

First lets update the factory `test/factories/group_memberships.rb`

```ruby
FactoryBot.define do
  factory :group_membership do
    user { build(:user) }
    group { build(:group) }
    state { GroupMembership::MEMBERSHIP_STATES.sample }
  end
end
```

Lets also update the `groups` factory

`test/factories/groups.rb`

```ruby
FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    description { Faker::Lorem.paragraphs.join }
    group_type { Group::GROUP_TYPES.sample }
    association :admin, factory: :user, strategy: :build

    after(:build) do |group|
      group.banner.attach(
        io: File.open(Rails.root.join("app", "assets", "images", "default_banner_img.png")),
        filename: "default_banner_img.png",
      )
    end
  end
end
```

Next lets update the test

`test/models/group_membership_test.rb`

```ruby
class GroupMembershipTest < ActiveSupport::TestCase
  subject { build(:group_membership) }

  context "associations" do
    should belong_to(:user)
    should belong_to(:group)
  end

  context "validations" do
    should validate_uniqueness_of(:user).scoped_to(:group_id)
    should validate_inclusion_of(:state)
             .in_array(GroupMembership::MEMBERSHIP_STATES)
  end

  test "#pending only returns pending memberships" do
    create_list :group_membership, 10
    GroupMembership.pending.each do |gm|
      assert gm.state == GroupMembership::PENDING
    end
  end

  test "#accepted only returns accepted memberships" do
    create_list :group_membership, 10
    GroupMembership.accepted.each do |gm|
      assert gm.state == GroupMembership::ACCEPTED
    end
  end
end
```

Similar to the answer model test, we are also using the `shoulda-matchers` helper methods to test the active record associations and validations of the `group_membership` model.
Note that we are opening our test by creating a test subject. This is because of how `shoulda-matcher` works for models with database indexes. Since our group_membership has `not-null` foreign keys to both `user` and `group`, ActiveRecord will raise a `PG:NotNullViolation` error when `shoulda-matcher` attempts to check for uniqueness by creating different `group_membership` objects (some of them with `user_id` or `group_id` of null). Therefore it is important that we provide the matcher with a record where the critical attributes are filled in with valid values beforehand. This is why we are providing a `subject`.

Now lets test the `group` model

Update `group_test.rb`

```ruby
class GroupTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:admin).class_name("User")
    should have_many(:group_memberships).dependent(:destroy)
    should have_many(:questions).dependent(:destroy)
    should have_many(:users)
             .through(:group_memberships)
             .source(:user)
    should have_many(:active_users)
             .through(:group_memberships)
             .source(:user)
  end

  context "validations" do
    should validate_presence_of(:name)
    should validate_presence_of(:description)
    should validate_presence_of(:banner)
    should validate_inclusion_of(:group_type)
             .in_array(Group::GROUP_TYPES)
    should have_one_attached(:banner)
    should validate_length_of(:name)
             .is_at_least(5)
             .is_at_most(30)
  end

  test "#active_users returns only accepted memberships" do
    g = create(:group)
    create_list(:group_membership, 10, group: g)
    g.active_users.each do |u|
      GroupMembership
        .find_by(user: u, group: g)
        .state == GroupMembership::ACCEPTED
    end
  end

  test "#ranked orders by # of questions & # of users" do
    g1 = create(:group)
    create_list :question, 3, group: g1
    create_list :group_membership, 2, group: g1

    g2 = create(:group)
    create_list :question, 5, group: g2
    create_list :group_membership, 6, group: g2

    g3 = create(:group)
    create_list :question, 3, group: g3
    create_list :group_membership, 3, group: g3

    assert Group.ranked.first == g2
    assert Group.ranked.second == g3
    assert Group.ranked.last == g1
  end

  test "#popular returns top 5 groups with most questions & users" do
    create_list :group, 11
    Group.all.each do |g|
      create_list :group_membership, rand(5..10), group: g
      create_list :question,
                  rand(5..10),
                  group: g,
                  user: g.active_users.sample
    end

    assert Group.popular.length == 5

    first = Group.popular.first
    second = Group.popular.second
    third = Group.popular.third
    fourth = Group.popular.fourth
    last = Group.popular.last

    assert first.questions.count + first.users.count \
             >= second.questions.count + second.users.count
    assert second.questions.count + second.users.count \
             >= third.questions.count + third.users.count
    assert third.questions.count + third.users.count \
             >= fourth.questions.count + fourth.users.count
    assert fourth.questions.count + fourth.users.count \
             >= last.questions.count + last.users.count
  end

  context "callbacks" do
    should callback(:add_admin_to_users).after(:create)
  end

  test "#add_admin_to_users" do
    admin = create :user
    g = create :group, admin: admin
    assert g.active_users.include?(admin)
  end
end
```

The above tests are similar to the ones we have written for the previous models.

Note that we are using a `should callback` method for checking that the `:add_admin_to_users` callback is called after creating a group. This method is provided by `shoulda-matchers` sister gem called `shoulda-callback-matchers`. It provides matchers to test before, after and around hooks.

Lets install the gem

```
$ bundle add shoulda-callback-matchers --group=test
```

Update the shoulda-matchers configuration in `test/test_helper.rb`

```ruby
...
...

Shoulda::Matchers.configure do |config|
  include Shoulda::Callback::Matchers::ActiveModel
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
```
