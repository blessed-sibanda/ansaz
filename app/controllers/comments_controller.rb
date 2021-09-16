class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @answer = Answer.find(params[:comment][:answer_id])
    question = @answer.question
    respond_to do |format|
      if @comment.save
        format.html do
          redirect_to question_path(question, anchor: ActionView::RecordIdentifier.dom_id(@comment))
        end
        format.js
      else
        format.html do
          redirect_to question, alert: "Error creating comment"
        end
        format.js
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content,
                                    :commentable_id, :commentable_type)
  end
end
