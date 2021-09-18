class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @answer = Answer.find(params[:comment][:answer_id])
    question = @answer.question
    respond_to do |format|
      if @comment.save
        format.js
      else
        format.js do
          redirect_to question, alert: "Error creating comment"
        end
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    authorize @comment
    @comment.destroy
    respond_to do |format|
      format.js
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content,
                                    :commentable_id, :commentable_type)
  end
end
