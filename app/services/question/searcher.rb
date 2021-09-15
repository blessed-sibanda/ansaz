class Question::Searcher < ApplicationService
  attr_reader :keyword, :conditions, :args, :tags_query, :base_query
  private :keyword, :conditions, :args, :tags_query, :base_query

  def initialize(keyword:, ungrouped: false)
    @keyword = keyword
    @conditions = ""
    @args = []

    if ungrouped
      @base_query = Question.ungrouped
        .joins(:action_text_rich_text, :tags)
        .order(created_at: :desc)
    else
      @base_query = Question
        .joins(:action_text_rich_text, :tags)
        .order(created_at: :desc)
    end
  end

  def call
    perform_search.order("title asc")
  end

  private

  def perform_search
    build_for_title_search
    build_for_content_search
    build_for_tag_list_search
    base_query.where(conditions, *args)
      .or(base_query.where(tags_query))
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
    cleaned_keyword = keyword.gsub(/[^A-Za-z-,]/, "").downcase.strip
    @tags_query = "tags.name in ('" + cleaned_keyword.split(",").join("','") + "')"
  end

  def formatted_keyword
    "%" + keyword + "%"
  end
end
