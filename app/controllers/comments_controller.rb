class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    question = Answer.find(params[:comment][:answer_id]).question
    if @comment.save
      redirect_to question_path(question, anchor: ActionView::RecordIdentifier.dom_id(@comment))
    else
      redirect_to question, alert: "Error creating comment"
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content,
                                    :commentable_id, :commentable_type)
  end
end
