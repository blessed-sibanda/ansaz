module QuestionsHelper
  def on_question_page?
    controller.action_name == "show" &&
      controller.controller_name == "questions"
  end
end
