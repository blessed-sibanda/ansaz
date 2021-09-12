require "test_helper"

class QuestionMailerTest < ActionMailer::TestCase
  test "answered" do
    mail = QuestionMailer.answered
    assert_equal "Answered", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
