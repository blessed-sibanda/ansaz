class TagsController < ApplicationController
  layout false

  def index
    @tags = Tag.where("name ilike ?", "%" + params["q"].split(",").last + "%")
  end
end
