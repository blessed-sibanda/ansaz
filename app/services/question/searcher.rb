class Question::Searcher < ApplicationService
  attr_reader :keyword, :where_clause, :where_args, :order
  private :keyword, :where_clause, :where_args, :order

  def initialize(keyword:)
    @keyword = keyword.downcase
    @where_clause = ""
    @where_args = []
    @order = {}
  end

  def call
    perform_search
  end

  private

  def perform_search
    build_for_title_search
    build_for_content_search
    build_for_tag_list_search
    Question.where(where_clause, *where_args).order(order)
  end

  def build_for_title_search
    @where_clause << "lower(title) like ?"
    @where_args << formatted_keyword
    @order = "title asc"
  end

  def build_for_content_search; end
  def build_for_tag_list_search; end

  def formatted_keyword
    keyword + "%"
  end
end
