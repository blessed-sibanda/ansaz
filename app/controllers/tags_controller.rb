class TagsController < ApplicationController
  layout false

  def index
    @tags = Tag.all
  end
end
