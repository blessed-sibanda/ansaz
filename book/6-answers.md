# 6 Answers

## Scaffold Answers

```bash
rails g scaffold answer user:references question:belongs_to accepted:boolean --skip-stylesheets
```

Update the `accepted` field in the migration to have a default value of `false`

```ruby
class CreateAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :answers do |t|
      t.references :user, null: false, foreign_key: true
      t.belongs_to :question, null: false, foreign_key: true
      t.boolean :accepted, default: false

      t.timestamps
    end
  end
end
```

```bash
rails db:migrate
```

Nest answers routes inside questions
`config/routes.rb`

```ruby
Rails.application.routes.draw do
  devise_for :users
  authenticate :user do
    resources :users, only: [:index, :show]
    resources :questions do
      resources :answers
    end
  end
  root to: "home#index"
end
```

Add rich text to answer model

```ruby
class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question
  has_rich_text :content
end
```

Update question model with answers

```ruby
class Question < ApplicationRecord
  belongs_to :user
  has_rich_text :content
  has_many :answers
end
```

Update user model with answers

```ruby
class User < ApplicationRecord
  ...
  ...
  has_many :answers
end
```

Update answers controller

- to use current-user as owner of answer

- to load the associated question before creating an answer

- to only accept answer `:content` in `answer_params` method

- to redirect to question page after creating an answers

```ruby
class AnswersController < ApplicationController
  before_action :set_question, only: %i[index create new]
  before_action :set_answer, only: %i[ show edit update destroy ]

  ...
  ...

  def create
    @answer = current_user.answers.build(answer_params)
    @answer.question = @question

    respond_to do |format|
      if @answer.save
        format.html { redirect_to @answer.question, notice: "Answer was successfully created." }
        format.json { render :show, status: :created, location: @answer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  ...
  ...

  private
    def set_answer
      @answer = Answer.find(params[:id])
    end

    def answer_params
      params.require(:answer).permit(:content)
    end

    def set_question
      @question = Question.find(params[:question_id])
    end
end
```

Update answer form

- Remove `:user_id`, `:question_id` and `:accepted` from the form fields
- Use `bootstrap_form_for` instead of `form_for` to style our form
- Add the rich text field for answer content

```erb
<%= bootstrap_form_with(model: [@question, answer]) do |form| %>
  <%= render 'shared/form_errors', resource: answer %>
  <div class="field">
    <%= form.rich_text_area :content %>
  </div>
  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

Show answer 'form' in question 'show' page and display the questions' answers
`app/views/questions/show.html.erb`

```erb
<%= render @question do %>
  <div class="my-2 pt-1"><%= @question.content %></div>
<% end %>
<%= render 'answers/form', answer: Answer.new %>
<hr>
<% if @question.answers.any? %>
  <h5>Answers (<%= @question.answers.count %>)</h5>
<% end %>
<%= render @question.answers %>
```

Create answer partial

```bash
touch app/views/answers/_answer.html.erb
```

`app/views/answers/_answer.html.erb`

```erb
<div class="card my-3 answer-card">
  <div class="card-header d-flex align-items-center justify-content-between">
    <%= link_to answer.user, class: 'd-flex align-items-center text-decoration-none' do %>
      <%= user_avatar(answer.user, height: 35, width: 35) %>
      <span class='ms-2'><%= answer.user.name %></span>
    <% end %>
    <span class='text-muted small'>
      <%= answer.created_at.to_s(:short) %>
    </span>
  </div>
  <div class="card-body"><%= answer.content %></div>
</div>
```

Now if you visit a question page and provide an answer, it looks like this

![Question Page with Answers](./question-with-answers.png)

## Update User Page

In this section, we will update the user profile page to show the user's questions and answers
