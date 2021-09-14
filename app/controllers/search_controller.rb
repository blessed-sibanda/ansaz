class SearchController < ApplicationController
  def index
    keyword = params[:keyword]
    debugger
    @questions = keyword.nil? ? nil : Question::Searcher.call(keyword: keyword)
  end
end
