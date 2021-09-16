class QuestionMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.question_mailer.answered.subject
  #
  def answered(question)
    @question = question

    mail to: question.user.email
  end
end
