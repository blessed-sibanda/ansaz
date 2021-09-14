class SearchController < ApplicationController
  def index
    @questions = Question.ungrouped
  end
end
