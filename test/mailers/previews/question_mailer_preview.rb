# Preview all emails at http://localhost:3000/rails/mailers/question_mailer
class QuestionMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/question_mailer/answered
  def answered
    QuestionMailer.answered(Question.first)
  end
end
