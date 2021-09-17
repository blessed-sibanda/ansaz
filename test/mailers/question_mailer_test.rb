require "test_helper"

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
