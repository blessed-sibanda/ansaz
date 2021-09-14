class Question::Searcher < ApplicationService
  attr_reader :keyword, :conditions, :args, :tags_query
  private :keyword, :conditions, :args, :tags_query

  def initialize(keyword:)
    @keyword = keyword
    @conditions = ""
    @args = []
  end

  def call
    build_query

    # Question.joins(:action_text_rich_text, :tags)
    #   .where(conditions, *args).or(Question.joins(:action_text_rich_text, :tags).where(tags_query))
    #   .order("title asc")
    # puts query
    # query

    Question.joins(:tags).where(tags_query)
  end

  private

  def build_query
    # build_for_title_search
    # build_for_content_search
    build_for_tag_list_search
  end

  def build_for_title_search
    @conditions << "title ilike ? "
    @args << formatted_keyword
  end

  def build_for_content_search
    @conditions << "OR action_text_rich_texts.body ilike ? "
    @args << formatted_keyword
  end

  def build_for_tag_list_search
    # Remove suspicious characters from keyword
    cleaned_keyword = keyword.gsub(/[^A-Za-z]-,/, "").downcase
    @tags_query = "tags.name in ('" + cleaned_keyword.split(",").join("','") + "')"
  end

  def formatted_keyword
    "%" + keyword + "%"
  end
end
