# 9 Testing

In this chapter we are going to write test code to always ensure that our application works as expected.

## 9.1 Testing Models

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
    password { "1234pass" }
    about { Faker::Lorem.paragraphs.join }

    trait :active do
      confirmed_at { Time.zone.now }
    end
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

    trait :grouped do
      association :group, strategy: :build
    end
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
    assert_changes("ActionMailer::Base.deliveries.size",
                   from: 0, to: 1) do
      perform_enqueued_jobs { create(:answer) }
    end

    email = ActionMailer::Base.deliveries.last
    assert email.subject == "Answered"
    assert email.to == [Answer.last.question.user.email]
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
    user
    group
    state { GroupMembership::MEMBERSHIP_STATES.sample }

    trait :accepted do
      state { GroupMembership::ACCEPTED }
    end

    trait :pending do
      state { GroupMembership::PENDING }
    end
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

```
$ rails test test/models/group_membership_test.rb
```

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

Now run the test

```
$ rails test test/models/group_test.rb
```

Now lets test the `question` model

```ruby
class QuestionTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:title)
  end

  should have_rich_text(:content)

  context "associations" do
    should belong_to(:user)
    should belong_to(:group).optional
    should have_many(:stars)
    should have_many(:answers)
    should have_many(:tags)
  end

  test "#ungrouped returns questions without groups" do
    create_list :question, 3, :grouped
    assert Question.ungrouped.count == 0

    create_list :question, 4
    assert Question.ungrouped.count == 4

    Question.ungrouped.each do |q|
      assert q.group.nil?
    end
  end

  test "#popular orders questions by # of stars & # of answers" do
    create_list :question, 15
    Question.all.each do |q|
      create_list :answer, rand(3..10), question: q
      create_list :star, rand(3..10), starrable: q
    end
    assert_equal Question.popular.length, 10

    first = Question.popular.first
    second = Question.popular.first
    third = Question.popular.third
    fourth = Question.popular.fourth
    last = Question.popular.last

    assert first.answers.count + first.stars.count \
             >= second.answers.count + second.stars.count
    assert second.answers.count + second.stars.count \
             >= third.answers.count + third.stars.count
    assert third.answers.count + third.stars.count \
             >= fourth.answers.count + fourth.stars.count
    assert fourth.answers.count + fourth.stars.count \
             >= last.answers.count + last.stars.count
  end

  test "#similar returns questions with similar tags" do
    q1 = create :question
    q1.tag_list = "people,love,food"
    q1.save!

    q2 = create :question
    q2.tag_list = "love,life,people"
    q2.save!

    q3 = create :question
    q3.tag_list = "food,love,chocolate"
    q3.save!

    assert_equal q1.similar(5).length, 2
    assert q1.similar(5).include?(q2)
    assert q1.similar(5).include?(q3)
  end
end
```

Run the test

```
$ rails test test/models/question_test.rb
```

Test the star model

```ruby
class StarTest < ActiveSupport::TestCase
  subject { build(:star) }

  context "associations" do
    should belong_to(:user)
    should belong_to(:starrable)
  end

  context "validations" do
    should validate_uniqueness_of(:user)
             .scoped_to([:starrable_id, :starrable_type])
  end
end
```

Run the tests

```
$ rails test test/models/star_test.rb
```

Using the same techniques as the ones above, lets test our last model - the user model

```ruby
class UserTest < ActiveSupport::TestCase
  context "associations" do
    should have_one_attached(:avatar)
    should have_many(:questions)
    should have_many(:answers)
    should have_many(:comments)
    should have_many(:stars)
    should have_many(:group_memberships)
    should have_many(:groups).through(:group_memberships).source(:group)
    should have_many(:active_groups)
             .through(:group_memberships)
             .source(:group)
    should have_many(:owned_groups)
             .class_name("Group")
             .with_foreign_key("admin_id")
  end

  test "#active returns confirmed users" do
    create_list :user, 4
    create_list :user, 7, :unconfirmed

    assert User.active.count == 4

    User.active.each do |u|
      refute u.confirmed_at.nil?
    end
  end

  test "#ranked orders users by # of questions & # of answers in ascending order of creation date" do
    u1 = create(:user)
    3.times { create(:question, user: u1) }
    3.times { create(:answer, user: u1) }

    u2 = create(:user)
    5.times { create(:question, user: u2) }
    3.times { create(:answer, user: u2) }

    u3 = create(:user)
    3.times { create(:question, user: u3) }
    3.times { create(:answer, user: u3) }

    u4 = create(:user)
    3.times { create(:question, user: u4) }
    4.times { create(:answer, user: u4) }

    assert User.ranked.first == u2
    assert User.ranked.second == u4
    assert User.ranked.third == u1
    assert User.ranked.fourth == u3
  end

  test "#starred returns the star of a given user if it exists" do
    u1 = create :user
    u2 = create :user
    q = create :question
    s = create :star, user: u1, starrable: q

    assert u1.starred(q) == s
    assert u2.starred(q).nil?
  end

  test "#unowned_groups returns groups in the user is not an admin but accepted" do
    u = create :user

    g1 = create :group, admin: u
    g2 = create :group
    g3 = create :group
    g4 = create :group

    create :group_membership, :accepted, user: u, group: g2
    create :group_membership, :pending, user: u, group: g3
    create :group_membership, :accepted, user: u, group: g4

    assert_not_includes u.unowned_groups, g1
    assert_includes u.unowned_groups, g2
    assert_not_includes u.unowned_groups, g3
    assert_includes u.unowned_groups, g4
  end

  test "#joined_on returns time which user joined the group" do
    u = create :user
    g = create :group
    gm = create :group_membership, :accepted, user: u, group: g
    assert_equal u.joined_on(g), gm.created_at.strftime("%d %b %Y")
  end

  test "#pending_approval shows whether user has pending group membership" do
    u = create :user
    g1 = create :group
    create :group_membership, :accepted, user: u, group: g1
    refute u.pending_approval(g1)

    g2 = create :group
    gm = create :group_membership, :pending, user: u, group: g2
    assert u.pending_approval(g2)
  end
end
```

Run the test

```
$ rails test test/models/user_test.rb
```

Now run all the model tests

```
$ rails test:models
```

All the tests should pass

## 9.2 Testing Policies

In this section we will write tests for our Pundit policies

Lets start by install the `policy-assertions` gem to easily test our Pundit policies. The gem provides provides assertions and refutations for policies and strong parameters.

```
$ bundle add policy-assertions --group=test
```

Require the `policy-assertions` library in `test_helper.rb`

```ruby
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "policy_assertions"

...
...
```

Now lets test the `answer-policy`

First update the test to inherit from `PolicyAssertions::Test` instead of inheriting from `ActiveSupport::TestCase` class.

```ruby
class AnswerPolicyTest < PolicyAssertions::Test
  def test_accept
    question = create(:question)
    answer = create(:answer, question: question)

    assert_permit question.user, answer
    refute_permit create(:user), answer
    refute_permit nil, answer
  end
end
```

Here we are testing that the policy only allows the question asker to accept an answer. All the other users cannot mark the answer as accepted.

Run the test

```bash
$ rails t test/policies/answer_policy_test.rb
```

Lets test the `group_membership_policy`

```ruby
class GroupMembershipPolicyTest < PolicyAssertions::Test
  def test_accept_or_reject
    g = create(:group)
    gm = create :group_membership, group: g
    assert_permit g.admin, gm
    refute_permit create(:user), gm
    refute_permit nil, gm
  end
end
```

```bash
$ rails t test/policies/group_membership_policy_test.rb
```

Now lets test the `group_policy`

```ruby
class GroupPolicyTest < PolicyAssertions::Test
  def setup
    @group = create :group
    @membership = create(:group_membership, :accepted, group: @group)
  end

  def test_edit_and_update_and_destroy
    assert_permit @group.admin, @group
    refute_permit create(:user), @group
    refute_permit nil, @group
  end

  def test_leave
    refute_permit @group.admin, @group
    assert_permit @membership.user, @group
  end

  def test_join
    refute_permit @membership.user, @group
    assert_permit create(:user), @group
  end

  def test_participate
    assert_permit @membership.user, @group
    assert_permit @group.admin, @group
    refute_permit create(:user), @group
  end
end
```

Like the other policy tests that we have written, the `group-policy-test` also inherits from `PolicyAssertions::Test`.

We are using the `setup` method to set the `@group` and `@membership` instance variables that we are using thorughout the test. The `policy-assertions` gem allows us to test multiple policy methods by combining the individual policy methods with 'and'. So for testing the `edit`, `update`, and `destroy` methods at once we use the `test_edit_and_update_and_destroy` test method. In this test we are testing that only the group admin can 'edit', 'update' and/or 'destroy' a given group.

In the `test_leave` method we are testing that only non-admin users can leave the group. The admin cannot leave (he/she will have to delete the group to get rid of it).

All in all, the test methods are pretty straightforward, i.e they are only checking what is in the corresponding policy method.

Run the test

```
$ rails t test/policies/group_policy_test.rb
```

Now lets test the `question_policy`

```ruby
class QuestionPolicyTest < PolicyAssertions::Test
  def test_update_and_destroy
    q = create :question
    assert_permit q.user, q
    refute_permit create(:user), q
  end
end
```

```bash
$ rails t test/policies/question_policy_test.rb
```

Finally lets finish off testing our policies, by updating the `star_policy_test` as follows

```ruby
class StarPolicyTest < PolicyAssertions::Test
  def test_destroy
    s = create :star
    assert_permit s.user, s
    refute_permit create(:user), s
  end
end
```

Now run the all the policy tests

```bash
$ rails t test/policies/
```

## 9.3 Testing Mailers

In this section we are going to test our mailers (its just one mailer actually).

Update the generated `test/mailers/question_mailer_test.rb`

```ruby
class QuestionMailerTest < ActionMailer::TestCase
  test "answered" do
    q = create :question
    mail = QuestionMailer.answered(q)
    assert_equal "Answered", mail.subject
    assert_equal [q.user.email], mail.to
    assert_equal ["noreply@ansaz.domain"], mail.from
    assert_match %r{Your Question}, mail.body.encoded
    assert_match %r{#{q.title}}, mail.body.encoded
    assert_match %r{has been answered.}, mail.body.encoded
  end
end
```

Run the mailers tests

```bash
$ rails test:mailers
```

## 9.4 Testing Services

In this section we are going to test our `group_membership` creator service.

Create the test file

```bash
$ mkdir test/services/group_membership -p
$ touch test/services/group_membership/creator_test.rb
```

Add the following code to the test file

```ruby
require "test_helper"

class GroupMembership::CreatorTest < ActiveSupport::TestCase
  test "joining a public group" do
    g = create :group, :public
    u = create :user
    assert_difference "GroupMembership.count", 1 do
      message = GroupMembership::Creator.call(user: u, group: g)
      assert_equal message, "You have joined '#{g.name}' group"
      assert_equal GroupMembership.last.state, GroupMembership::ACCEPTED
    end
  end

  test "joining a private group" do
    g = create :group, :private
    u = create :user
    assert_difference "GroupMembership.count", 1 do
      message = GroupMembership::Creator.call(user: u, group: g)
      assert_equal message, "A request to join '#{g.name}' has been sent"
      assert_equal GroupMembership.last.state, GroupMembership::PENDING
    end
  end

  test "group admin is already in the group" do
    g = create :group, :private
    assert_difference "GroupMembership.count", 0 do
      message = GroupMembership::Creator.call(user: g.admin, group: g)
      assert_equal message, "You are already in this group"
      assert_equal GroupMembership.last.state, GroupMembership::ACCEPTED
    end
  end
end
```

The test checkes the different messages and group-membership states that are created when a user joins a private or a public group. The test also asserts that the group admin is already in the group, so no new membership is created.

Run the test

```
$ rails test test/services/
```

## 9.5 Testing Controllers

In this section we will now move on to testing the meat and bones of our application - the controllers.

Let's start by updating our `test_helper` with Devise test helper methods.

`test/test_helper.rb`

```ruby
...
...

module ActionController
  class TestCase
    include Devise::Test::ControllerHelpers
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end
```

Now let's test the home controller

`test/controllers/home_controller_test.rb`

```ruby
class HomeControllerTest < ActionDispatch::IntegrationTest
  test "index redirects unauthenticated users to login page" do
    get root_url
    assert_redirected_to new_user_session_url
  end

  test "index redirects authenticated users to questions page" do
    sign_in create(:user)
    get root_url
    assert_redirected_to questions_url
  end
end
```

The test checks the redirections based on the user's authentication status. Also note that we are using the Devise `sign_in` test helper method to login our user.

Run the test and see that it passses

```bash
$ rails t test/controllers/home_controller_test.rb
```

Now lets test the questions controller. Update the `QuestionsControllerTest` with a `setup` method that authenticates the question owner.

`test/controllers/questions_controller_test.rb`

```ruby
class QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @question = create :question
    @user = @question.user
    sign_in(@user)
  end

  ...
  ...
end
```

That is all that's needed to make this scaffolded `questions-controller-test` pass.

```bash
$ rails t test/controllers/questions_controller_test.rb
```

Now lets generate a 'questions' integration test to test the modifications that we made to `questions_controller` in addition to what rails generated for us.

```
$ rails g integration_test questions
```

`test/integration/questions_test.rb`

```ruby
class QuestionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  def assert_question_info(q)
    assert_select "#question_#{q.id}" do
      assert_select "a[href=?]", question_path(q), text: q.title
      assert_select "img", count: 1
      if Pundit.policy!(@user, q).edit?
        assert_select "a[href=?]", question_path(q), text: "Edit"
      end
      if Pundit.policy!(@user, q).destroy?
        assert_select "a[href=?]", question_path(q), text: "Delete"
      end

      q.tags.each do |tag|
        assert_select "a[href=?]", tag_path(tag), text: "##{tag.name}"
      end

      assert_select "#question_#{q.id}_stars" do
        assert_select "a", %r{#{q.stars.count} star}
      end
    end
  end

  test "questions are paginated" do
    sign_in @user
    create_list :question, 25
    get questions_url
    page1 = Question.paginated(1)
    page1.each { |q| assert_question_info(q) }

    assert_select "nav>ul.pagination" do
      assert_select "li>a[href=?]", questions_path(page: 2)
      assert_select "li>a[href=?]", questions_path(page: 3)
    end
  end

  test "question page displays the answers" do
    sign_in @user
    q = create :question
    create_list :answer, 5, question: q
    get question_path(q)
    assert_question_info(q)
    assert_select "div", text: q.content.to_plain_text

    q.answers.ranked.each do |a|
      assert_select "#answer_#{a.id}" do
        assert_select "div", a.content.to_plain_text
      end
    end
  end
end
```

In this test we are using `assert_select` a lot to make assertions against the returned HTML response. Note that `assert_select` accepts a CSS selector to check for the presence of the element matching the selector.
