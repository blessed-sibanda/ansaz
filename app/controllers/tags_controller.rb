class TagsController < ApplicationController
  layout false

  def index
    @tags = ActsAsTaggableOn::Tag.where("name ilike ?", "%" + params["q"].split(",").last + "%")
  end

  def show
    page = params[:page]
    @questions = Question.tagged_with(params[:id]).paginated(page)
    render "show", layout: "application"
  end
end
