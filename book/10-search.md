# 10 Searching for Questions

Our users can now join groups and ask questions in those groups. In this chapter we will implement a question search feature.

## 10.1 Implementing Full-text Search

This search feature will allow users to find questions based on title and/or content. To implement our search, we are going to take advanced of the built-in PostgreSQL full-text search capabilities using a gem called `pg-search`. This gem does all the heavy lifting of dealing with things like `ts_vector` and `ts_query` behind the scenes for us. It is a perfect example of how ruby and rails makes life easier for us developers.

Lets install `pg_search`

```
$ bundle add pg_search
```

Include `PgSearch` in question model and provide a search scopes for question title and content.

```ruby
class Question < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_title, against: :title
  pg_search_scope :search_content,
                  associated_against: {
                    rich_text_content: [:body],
                  }

  ...
  ...

  def self.search(keyword)
    a = search_content(keyword).pluck(:id)
    b = search_title(keyword).pluck(:id)
    ids = (a + b).uniq
    where(id: ids)
  end
end
```

Update the questions controller index action to allow for search

```ruby
class QuestionsController < ApplicationController
  before_action :set_question, only: %i[ show edit update destroy ]
  before_action :authorize_question, only: [:edit, :update, :destory]

  def index
    keywords = params[:keywords]
    page = params[:page]
    if keywords.nil?
      @questions = Question.paginated(page)
    else
      @questions = Question.search(keywords).paginated(page)
    end
  end

  ...
  ...
end
```

The paginated scope paginates the questions and orders them in descending order of creation date. It also filters questions by group_id if the group is given.

```ruby
class Question < ApplicationRecord
  ...

  scope :paginated, ->(page, group: nil) {
      where(group: group&.id)
        .paginate(page: page, per_page: 10)
        .order(created_at: :desc)
    }
end
```

Now lets update our navbar search form to send our searches via `get` to the `questions_url`.

```erb
<nav class="navbar navbar-expand-lg navbar-light bg-light sticky-top">
  <div class="container">
    ...
    ...
    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        ...
        ...
      </ul>
      <%= form_for :search, url: questions_url, method: :get, html: {class: 'd-flex'} do |f| %>
        <%= text_field_tag :keywords, nil, placeholder: 'Search questions...', class: 'form-control me-2' %>
        <button class="btn btn-outline-success" type="submit">Search</button>
      <% end %>
    </div>
  </nav>
```

Now update the questions index page with different headers based on whether the results are search results or not.

```erb
<div class="d-flex justify-content-between align-items-center my-2">
  <% if @keywords %>
    <h1 class="h5">Search Results for
      <span class='text-warning'>"<%= @keywords %>"</span>
    </h1>
  <% else %>
    <h1 class="h5 text-uppercase">Questions</h1>
    <%= link_to 'New Question', new_question_path, class: 'btn btn-primary' %>
  <% end %>
</div>
...
<%= content_for :sidebar do %>
  ...
<% end %>
```

# 10.2 Searching for Questions By Tags
