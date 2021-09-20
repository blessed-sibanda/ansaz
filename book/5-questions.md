# 5 Asking Questions

In this chapter we are going to allow users to create questions. The questions will be displayed in the home page.

## 5.1 Scaffold questions

```
$ rails g scaffold question title user:references --skip-stylesheets
```

Update `routes.rb` to only allow authenticated users to access `questions` controller actions

```ruby
Rails.application.routes.draw do
  devise_for :users
  authenticate :user do
    resources :users, only: [:index, :show]
    resources :questions
  end
  root to: "home#index"
end
```

Add presence validation to question `title`

```ruby
class Question < ApplicationRecord
  ...
  ...

  validates :title, presence: true
end

```

Run migrations

```
$ rails db:migrate
```

Add `questions` to user model
`app/models/user.rb`

```ruby
class User < ApplicationRecord
  ...
  ...

  has_many :questions
end
```

Refactor question form

- Remove `user_id` from the form fields
- Refactor form errors into a separate partial
- User `bootstrap_form_for` instead of `form_for`

Refactoring form errors

```bash
$ mkdir app/views/shared

$ touch app/views/shared/_form_errors.html.erb
```

```erb
<% if resource.errors.any? %>
  <div id="error_explanation">
    <h2 class='h6'><%= pluralize(resource.errors.count, "error") %> prohibited this <%= resource.class.name.downcase %> from being saved:</h2>
    <ul>
      <% resource.errors.each do |error| %>
        <li class='small'><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

Update question `form` partial
`app/views/questions/_form.html.erb`

```erb
<%= bootstrap_form_with(model: question) do |form| %>
  <%= render 'shared/form_errors', resource: question %>
  <div class="field">
    <%= form.text_field :title %>
  </div>
  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

Add `questions resource` inside the `authenticate :user` block in `config/routes.rb`

```ruby
Rails.application.routes.draw do
  ...
  authenticate :user do
    resources :user_profiles, except: [:destroy, :index]
    resources :questions
  end
  ...
end
```

Update `questions-controller`

- Update the `create` action to assign the questions to the `current_user`

- Remove `:user_id` from 'question_params'

`app/controllers/questions_controller.rb`

```ruby
class QuestionsController < ApplicationController
  ...

  # POST /questions or /questions.json
  def create
    @question = current_user.questions.build(question_params)

    respond_to do |format|
      ...
      ...
    end
  end

  ...

  private

  ...
  ...

  def question_params
    params.require(:question).permit(:title)
  end
end
```

Update questions `index` page

```erb
<div class="d-flex justify-content-between align-items-center my-2">
  <h1 class='h5 text-uppercase'>Questions</h1>
  <%= link_to 'New Question', new_question_path, class: 'btn btn-primary' %>
</div>
<%= render @questions %>
```

Create `question` partial

```bash
$ touch app/views/questions/_question.html.erb
```

`app/views/questions/_question.html.erb`

```erb
<p class='small text-muted fw-bold mb-0 pb-0'><%= question.created_at.to_s(:long) %></p>
<div class="card question-card mt-0 mb-3 border-0 bg-light border-top">
  <div class="card-body py-2">
    <h6 class="card-title fw-light d-flex justify-content-between">
      <div class='d-flex align-items-center'>
        <%= user_avatar(question.user, height: 35, width: 35) %>
        <div class='ms-2'>
          <%= question.user.name %>
          <span class='text-muted small'>asked</span>
        </div>
      </div>
      <div class='d-flex align-items-center'>
        <%= link_to 'Edit', edit_question_path(question), class: 'small fw-bold text-decoration-none link-warning' %>
        <span class="mx-1"></span>
        <%= link_to 'Delete', question, method: :delete, data: {confirm: 'Are you sure?'}, class: 'small fw-bold text-decoration-none link-danger' %>
      </div>
    </h6>
    <h5 class="card-subtitle fw-normal mt-3">
      <%= link_to question.title, question, class: 'text-decoration-none' %>
    </h5>
  </div>
</div>

```

Order questions in descending order(i.e newer questiosns first)

```ruby
class QuestionsController < ApplicationController
  ...
  ...

  def index
    @questions = Question.all.order(created_at: :desc)
  end

  ...
  ...
end
```

Update the `home controller` to redirect to questions path when user is logged in otherwise redirect to login page.

```ruby
class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to questions_path
    else
      redirect_to new_user_session_path
    end
  end
end
```

## 5.2 Add Rich Text to Questions

```bash
rails action_text:install

# Run Migrations
rails db:migrate
```

Add rich text to question model

`question.rb`

```ruby
class Question < ApplicationRecord
  belongs_to :user
  has_rich_text :content
end
```

Update question `form` to include _rich text_

```ruby
<%= bootstrap_form_with(model: question) do |form| %>
  <%= render 'shared/form_errors', resource: question %>
  <div class="field">
    <%= form.text_field :title %>
  </div>
  <div class="field">
    <%= form.rich_text_area :content %>
  </div>
  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

Update questions `new` page

`app/views/questions/new.html.erb`

```erb
<h1 class='h2'>New Question</h1>
<%= render 'form', question: @question %>
<%= link_to 'Back', questions_path %>
```

Update questions `edit` page
`app/views/questions/edit.html.erb`

```erb
<h1 class='h2'>Editing Question</h1>
<%= render 'form', question: @question %>
<%= link_to 'Show', @question %> |
<%= link_to 'Back', questions_path %>
```

Update `questions-controller` to accept question content in `questions_params`

```ruby
def question_params
  params.require(:question).permit(:title, :content)
end
```

Update 'question' partial as follows (so that we can re-use it in both the question index and show page)

```erb
<p class='small text-muted fw-bold mb-0 pb-0'><%= question.created_at.to_s(:long) %></p>
<div class="card question-card mt-0 mb-3 border-0 bg-light border-top">
  <div class="card-body py-2">
    ...
    ...
    <h5 class="card-subtitle fw-normal mt-3">
      <%= link_to question.title, question, class: 'text-decoration-none' %>
    </h5>
    <%= yield if on_question_page? %>
  </div>
</div>

```

Create the `on_question_page?` helper in `questions_helper.rb` to check whether the user is on the `show` question page.

`app/helpers/questions_helper.rb`

```ruby
module QuestionsHelper
  def on_question_page?
    controller.action_name == "show" &&
      controller.controller_name == "questions"
  end
end
```

Display question content in question show page

`app/views/questions/show.html.erb`

```
<%= render @question do %>
  <div class="my-2 pt-1"><%= @question.content %></div>
<% end %>
```

Update the `db/seeds.rb` with questions data

```ruby
...
...

20.times do |i|
  Question.create!(
    user: User.active.sample,
    title: Faker::Lorem.sentence(word_count: rand(5..10)),
    content: Faker::Lorem.sentence(word_count: rand(75..150)),
  )
end
```

Seed the database

```
$ rails db:seed:replant
```

Now if you login and visit the home page, you will see the questions list

## 5.3 User Authorization

We are going to use the `pundit` gem to build a robust authorization system in our application.

Setup pundit

```
$ bundle add pundit
$ rails g pundit:install
```

Include `Pundit` in `ApplicationController` and a method to flash an alert message when a user attempts to perform an action they are unauthorized to perform.

```ruby
class ApplicationController < ActionController::Base
  include Pundit
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  ...
  ...

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:alert] = t "#{policy_name}.#{exception.query}",
                      scope: "pundit", default: :default
    redirect_to(request.referrer || root_path)
  end
end
```

Create a pundit question policy

```
$ rails g pundit:policy question
```

Only allow the owner of the question to update/delete a question. To do that, add the `update?` and `destroy?` method in question policy.

`app/policies/question_policy.rb`

```ruby
class QuestionPolicy < ApplicationPolicy
  def update?
    user == record.user
  end

  def destroy?
    user == record.user
  end
end
```

Update `config/locales/en.yml` with pundit messages for question policy

```yml
en:
  pundit:
    default: 'You cannot perform this action.'
    question_policy:
      edit?: 'Only question owner can edit the question!'
      update?: 'Only question owner can update the question!'
      destroy?: 'Only question owner can delete the question!'
```

Update the `Edit` and `Destroy` links in question partial
`_question.html.erb`

```erb
<p class='small text-muted fw-bold mb-0 pb-0'><%= question.created_at.to_s(:long) %></p>
<div class="card question-card mt-0 mb-3 border-0 bg-light border-top">
  <div class="card-body py-2">
    <div>
      <h6 class="card-title fw-light d-flex justify-content-between">
        ...
        ...
        <div class='d-flex align-items-center'>
          <% if policy(question).update? %>
            <%= link_to 'Edit', edit_question_path(question), class: 'small fw-bold text-decoration-none link-warning' %>
          <% end %>
          <span class="mx-1"></span>
          <% if policy(question).destroy? %>
            <%= link_to 'Delete', question, method: :delete, data: {confirm: 'Are you sure?'}, class: 'small fw-bold text-decoration-none link-danger' %>
          <% end %>
        </div>
      </h6>
    </div>
    ...
    ...
  </div>
</div>
```

Update the `question-controller` to use the `question-policy` authorization

```ruby
class QuestionsController < ApplicationController
  before_action :set_question, only: %i[ show edit update destroy ]
  before_action :authorize_question, only: [:edit, :update, :destory]

  ...
  ...

  private

  ...

  def authorize_question
    authorize @question
  end
end
```

Now if you access the `edit` page of a question you did not create, Pundit will deny you access and present you with the following screen.

![Pundit Authorization](./pundit.png)

## 5.4 Tagging Questions

In this chapter we will allow users to tag their questions for easier discoverability and filtering. We are going to use the `acts-as-taggable-on` gem. This gem greatly simplifies the process of adding tags to active record models and also allows us to specify different tag "contexts" in the same model.

Lets install the gem

```
$ bundle add acts-as-taggable-on
```

Generate and run the migrations

```
$ rake acts_as_taggable_on_engine:install:migrations
$ rails db:migrate
```

Update the question model to include tags

```ruby
class Question < ApplicationRecord
  ...
  ...
  acts_as_taggable_on :tags
  ...
  ...
end
```

Display question tags in question partial

`app/views/questions/_question.html.erb`

```erb
<p class='small text-muted fw-bold mb-0 pb-0'><%= question.created_at.to_s(:long) %></p>
<div class="card question-card mt-0 mb-3 border-0 bg-light border-top">
  ...
  ...
  <div class="card-footer d-flex justify-content-between">
    <div>
      <%= render 'stars/stars', starrable: question %>
    </div>
    <div class="d-flex">
      <% question.tags.each do |tag| %>
        <%= link_to "##{tag.name}", '#', class: 'badge tag-item' %>
      <% end %>
    </div>
  </div>
</div>
```

Update `main.scss`

```scss
// previous styles here

a.tag-item {
  background: white;
  color: var(--bs-dark);
  text-decoration: none;
  margin: 0 0.3em;

  &:hover {
    color: white;
    background-color: var(--bs-gray);
  }
}
```

Update question form to include tags

```erb
<%= bootstrap_form_with(model: question) do |form| %>
  <%= render 'shared/form_errors', resource: question %>
  <div class="field">
    <%= form.text_field :title %>
  </div>
  <%= form.hidden_field :group_id, value: question.group&.id %>
  <div class="field">
    <%= form.rich_text_area :content %>
  </div>
  <div data-controller='tag'>
    <label for="">Tags</label>
    <small class="small text-muted">Separate tag names with commas</small>
    <div data-controller="autocomplete" data-autocomplete-url-value="/tags/">
      <input name='question[tag_list]' value='<%= question.tag_list.join(',') %>' type="text" class='form-control' data-tag-target='input' data-autocomplete-target="input"/>
      <ul class="list-group" data-autocomplete-target="results" style="max-height: 10rem; overflow-y: scroll;"></ul>
    </div>
  </div>
  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

Note that we are using markup to with `stimulus-autocomplete` controller. This is provided by the `stimulus-autocomplete` npm package. This package allows us to to make a selection from a list of results fetched from the server. In this case we want to fetch tag names from our server and provide autocomplete as the user types.

Lets install the npm package

```
$ yarn add stimulus-autocomplete
```

Setup `stimulus` to work with this new package

`app/javascript/controllers/index.js`

```javascript
import { Application } from 'stimulus';
import { definitionsFromContext } from 'stimulus/webpack-helpers';
import { Autocomplete } from 'stimulus-autocomplete';

const application = Application.start();
const context = require.context('controllers', true, /_controller\.js$/);
application.load(definitionsFromContext(context));

application.register('autocomplete', Autocomplete);
```

Create the tags rails controller to give us a list of tags based on the search query from the input.

```
$ rails g controller tags index show --skip-stylesheets
```

```ruby
class TagsController < ApplicationController
  layout false

  def index
    @tags = ActsAsTaggableOn::Tag.where("name ilike ?", "%" + params["q"].split(",").last + "%")
  end

  ...
  ...
end
```

Lets create the tag `index` view

```erb
<% @tags.each do |tag| %>
  <li id="<%= dom_id(tag) %>" class="list-group-item" role="option">
    <%= tag.name %>
  </li>
<% end %>
```

The index action in our tags controller uses `ilike` query to search for tags with names that contain the keyword entered in the input box.

Update routes

```ruby
Rails.application.routes.draw do
  root to: "home#index"
  devise_for :users
  authenticate :user do
    ...
    resources :tags, only: [:index, :show]
  end
end
```

Create a tags stimulus controller to override the default behaviour of `stimulus-autocomplete`.

To learn more about the `stimulus-autocomplete` package visit its [github page](https://github.com/afcapel/stimulus-autocomplete)

```
$ touch app/javascript/controllers/tag_controller
```

```javascript
import { Controller } from 'stimulus';

var inputValue = '';
export default class extends Controller {
  static targets = ['input'];
  connect() {
    document.addEventListener('autocomplete.change', this.change.bind(this));
    this.inputTarget.addEventListener('keyup', this.inputChanged.bind(this));
  }

  inputChanged(event) {
    if (event.key == ',') inputValue = event.target.value;
    if (this.inputTarget.value == '') {
      inputValue = '';
    }
  }

  change(event) {
    this.inputTarget.value = inputValue;
    if (!this.inputTarget.value.includes(event.detail.textValue)) {
      this.inputTarget.value += event.detail.textValue + ',';
      inputValue = this.inputTarget.value;
    }
  }
}
```

The above controller will allow concatenation of tag names as the user types

Update `questions_params` in questions controller to accept the tag list

```ruby
class QuestionsController < ApplicationController
  ...
  ...

  private

  ...
  def question_params
    params.require(:question).permit(:title, :content, :group_id, :tag_list)
  end
end
```

Now try creating a new question and you will notice the autocomplete feature working on the tag list

Update tags controller `show` action to allow filtering questions by tag names

```ruby
class TagsController < ApplicationController
  ...
  ...

  def show
    page = params[:page]
    @questions = Question.tagged_with(params[:id]).paginated(page)
    render "show", layout: "application"
  end
end
```

Note that we are using `tagged_with` method (provided by the `acts-as-taggable-on` gem) to retrieve questions with the given tag name.

Update tag `show` page

```erb
<%= render 'questions/questions', questions: @questions do %>
  <h1 class="h5">Questions tagged
    <span class='text-success'>'<%= params[:id] %>'</span>
  </h1>
  <%= link_to 'New Question', new_question_path, class: 'btn btn-primary' %>
<% end %>
```

Note that we are using a questions partial with a block to accept a different header based on whether the questions are search results or not.

Factor out the questions list (from the questions page) and replace the header with a `yield`

```
$ touch app/views/questions/_questions.html.erb
```

```erb
<div class="d-flex justify-content-between align-items-center my-2">
  <%= yield %>
</div>
<%= render questions %>
<%= will_paginate questions, renderer: WillPaginate::ActionView::BootstrapLinkRenderer %>
<%= content_for :sidebar do %>
  <%= render 'groups/popular' %>
<% end %>
```

Now update the questions `index` page

```erb
<%= render 'questions', questions: @questions do %>
  <h1 class="h5 text-uppercase">Questions</h1>
  <%= link_to 'New Question', new_question_path, class: 'btn btn-primary' %>
<% end %>
```

Update the question partial to allow filtering questions by tag names

```erb
<p class='small text-muted fw-bold mb-0 pb-0'><%= question.created_at.to_s(:long) %></p>
<div class="card question-card mt-0 mb-3 border-0 bg-light border-top">
  ...
  ...
  <div class="card-footer d-flex justify-content-between">
    ...
    ...
    <div class="d-flex">
      <% question.tags.each do |tag| %>
        <%= link_to "##{tag.name}", tag_path(tag.name), class: 'badge tag-item' %>
      <% end %>
    </div>
  </div>
</div>
```

## 5.5 Searching for Questions

In this chapter we will implement a question search feature. This search feature will allow users to find questions based on title, content and/or tags. To implement our search, we are going to take advantage of the built-in PostgreSQL full-text search capabilities using a gem called `pg-search`. This gem does all the heavy lifting in dealing with things like `ts_vector` and `ts_query` behind the scenes for us. It is a perfect example of how ruby and rails makes life easier for us developers.

Lets install `pg_search`

```
$ bundle add pg_search
```

Generate a migration to create the pg_search_documents database table.

```
$ rails g pg_search:migration:multisearch
$ rails db:migrate
```

Include `PgSearch` in question model and provide a search scopes for question title and content.

```ruby
class Question < ApplicationRecord
  ...

  include PgSearch::Model

  pg_search_scope :search,
                  against: :title,
                  associated_against: {
                    rich_text_content: [:body],
                    tags: [:name],
                  }
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
        <%= text_field_tag :keywords, nil, placeholder: 'Search public questions...', class: 'form-control me-2' %>
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

Update the database seeds with more data to see the search and tagging features in action

`db/seeds.rb`

```ruby
...
...

puts "Adding questions"
500.times do |i|
  include FactoryBot::Syntax::Methods
  q = create :question
  tags = []
  rand(1..3).times.each do
    tags << Faker::Educator.subject.downcase.gsub(/[^A-Za-z-]/, "")
  end

  q.tag_list = tags.uniq
  q.save!

  print(".") if i % 100 == 0
end
```
