class Question::Searcher < ApplicationService
  attr_reader :keyword, :conditions, :args
  private :keyword, :conditions, :args

  def initialize(keyword:)
    @keyword = keyword
    @conditions = ""
    @args = []
  end

  def call
    build_query
    Question.joins(:action_text_rich_text)
      .where(conditions, *args).order("title asc")
  end

  private

  def build_query
    build_for_title_search
    build_for_content_search
    build_for_tag_list_search
  end

  def build_for_title_search
    @conditions << "title ilike ?"
    @args << formatted_keyword
  end

  def build_for_content_search
    @conditions << "OR action_text_rich_texts.body ilike ?"
    @args << formatted_keyword
  end

  def build_for_tag_list_search; end

  def formatted_keyword
    "%" + keyword + "%"
  end
end
