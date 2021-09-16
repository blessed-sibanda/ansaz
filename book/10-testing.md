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

The test code is generally straightforward, we are using the `shoulda-matchers` helper methods to test the associations of `answer` with other models. We are also testing that an email is delivered to the question's asker whenever a new answer is created. It is also important to note that we are `perfom`ing `enqueued_jobs` before creating an answer because the email is 'delivered later' (i.e its delivered in a background job). We also check that the `Answer#parent_answer` returns the answer object itself.
