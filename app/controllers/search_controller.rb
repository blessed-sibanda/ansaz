class SearchController < ApplicationController
  def index
    keyword = params[:keyword]
    @questions = keyword.nil? ? nil : Question::Searcher.call(keyword: keyword)
    render "questions/index"
  end
end
