# 6 Answers

In this chapter we will allow users to provide answers to questions. Users will also be able to comment on answers and even on other's comments.

## 6.1 Scaffold Answers

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

## 6.2 Update User Profile Page

In this section, we will update the user profile page to show the user's questions and answers

`app/views/users/show.html.erb`

```erb
<%= render @user %>
<div data-controller='tab'>
  <ul class="nav nav-tabs mt-3">
    <li class="nav-item">
      <a data-tab-target='aboutLink' data-action="click->tab#about" class="nav-link active">About</a>
    </li>
    <li class="nav-item">
      <a data-tab-target='questionsLink' data-action="click->tab#questions" class="nav-link">Questions</a>
    </li>
    <li class="nav-item">
      <a data-tab-target='answersLink' data-action="click->tab#answers" class="nav-link">Answers</a>
    </li>
  </ul>
  <div class="tab-content" id="user-tabs">
    <div data-tab-target="about" class="tab-pane fade show active">
      <div class="lead"><%= @user.about %></div>
    </div>
    <div data-tab-target="questions" class="tab-pane fade">
      <%= render 'questions', user: @user %>
    </div>
    <div data-tab-target="answers" class="tab-pane fade">
      <%= render 'answers', user: @user %>
    </div>
  </div>
</div>
```

Note that we are using `data-controller`, `data-action` and `data-target` attributes in the html. These attributes are required by the `Stimulus JS` library that we will use for the interactivity of our tabs. Stimulus is a small javascript library for sprinkling bits of interactivity in your already existing html.

Lets install stimulus

```
$ rails webpacker:install:stimulus
```

Create a stimulus `tab` controller (to make our user tab interactive)

```
$ touch app/javascript/controllers/tab_controller.js
```

`app/javascript/controllers/tab_controller.js`

```javascript
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'about',
    'aboutLink',
    'questions',
    'questionsLink',
    'answers',
    'answersLink',
  ];

  reset() {
    this.element.querySelectorAll('ul>li>a.nav-link').forEach((item) => {
      item.classList.remove('active');
    });
    this.element.querySelectorAll('.tab-content>.tab-pane').forEach((item) => {
      item.classList.remove('active');
      item.classList.remove('show');
    });
  }

  about() {
    this.reset();
    this.aboutLinkTarget.classList.add('active');
    this.aboutTarget.classList.add('active');
    this.aboutTarget.classList.add('show');
  }

  answers() {
    this.reset();
    this.answersLinkTarget.classList.add('active');
    this.answersTarget.classList.add('active');
    this.answersTarget.classList.add('show');
  }

  questions() {
    this.reset();
    this.questionsLinkTarget.classList.add('active');
    this.questionsTarget.classList.add('active');
    this.questionsTarget.classList.add('show');
  }
}
```

Create the user `answers` partial to render the user's answers

```
$ touch app/views/users/_answers.html.erb
```

```erb
<% user.answers.each do |answer| %>
  <div class="card my-3 shadow-none border-1">
    <div class="card-header">
      <strong>Question:</strong>
      <%= link_to answer.question.title, answer.question, class: 'text-decoration-none' %>
    </div>
    <div class="card-body">
      <%= answer.content %>
    </div>
  </div>
<% end %>
```

Create the user `questions` partial to render the user's questions

```
$ touch app/views/users/_questions.html.erb
```

```erb
<% user.questions.each do |question| %>
  <div class="card my-2 border-0 border-bottom bg-light">
    <div class="card-body">
      <%= link_to question.title, question, class: 'card-title h5 text-decoration-none' %>
    </div>
  </div>
<% end %>
```

Now if you open a users profile page you see something like this

![User Profile Page](./user-profile.png)

## 6.3 Commenting on Answers

Create a comment model

```bash
$ rails g model comment user:references commentable:references{polymorphic} content:text
```

Run the migrations

```
$ rails db:migrate
```

Comments can be nested, so commentable_type can be either `Comment` or `Answer`

Validate Comment content with a presence validation

```ruby
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  validates :content, presence: true
end
```

Add comments to answer model

```ruby
class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question
  has_rich_text :answer
  has_many :comments, as: :commentable
end
```

Add comments to user model

```ruby
class User < ApplicationRecord
  ...
  ...
  has_many :comments
end
```

Add comments to comment model

```ruby
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  validates :comment, presence: true
  has_many :comments, as: :commentable
end
```

Create comments controller

```bash
$ rails g controller comments --skip-stylesheets
```

Update `config/routes.rb`

```ruby
Rails.application.routes.draw do
  devise_for :users
  authenticate :user do
    ...
    ...
    resources :comments
  end
  root to: "home#index"
end
```

Add `create` action to comments-controller

```ruby
class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_back(fallback_location: root_path)
    else
      redirect_back(fallback_location: root_path, alert: "Error creating comment")
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content,
                                    :commentable_id, :commentable_type)
  end
end
```

Update `answer` partial to allow for commenting

```erb
<div class="card my-3 answer-card">
  ...
  ...
  <div class="card-body">
    <%= answer.content %>
    <div class='mt-2 small text-muted'>
      <%= render 'comments/reply', commentable: answer %>
      <span class="mx-2">&middot;</span>
      <a class='text-decoration-none reply-link' href="#">Replies (<%= answer.comments.count %>)</a>
    </div>
  </div>
  <% comments = answer.comments.select(&:persisted?) %>
  <% if comments.any? %>
    <div class="card-footer bg-transparent">
      <h6>Comments</h6>
      <%= render comments %>
    </div>
  <% end %>
</div>
```

The comments/reply will contain a link to open a modal with a form to comment on the answer

```bash
$ touch app/views/comments/_reply.html.erb
```

`app/views/comments/_reply.html.erb`

```erb
<%= render 'shared/modal', commentable: commentable, modal_id: "commentable_#{commentable.id}", modal_title: "Reply #{commentable.class.name}" do %>
  <%= render partial: 'comments/form', locals: {comment: current_user.comments.build, commentable: commentable} %>
<% end %>
<a class='reply-link' href="#" data-bs-toggle="modal" data-bs-target='#<%= "commentable_#{commentable.id}" %>'>
  Reply
</a>
```

The reply partial itself will render a modal partial containing the comment form. The modal will have a unique 'id' and will use `yield` to display the content passed to its block.

```bash
$ touch app/views/shared/_modal.html.erb
```

`app/views/shared/_modal.html.erb`

```erb
<div class="modal fade" id="<%= modal_id %>">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">
          <%= modal_title %>
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" ></button>
      </div>
      <div class="modal-body">
        <div class="bg-light p-2">
          <%= commentable.content %></div>
        <%= yield %>
      </div>
    </div>
  </div>
</div>
```

Then create the comment form

```bash
$ touch app/views/comments/_form.html.erb
```

```erb
<%= bootstrap_form_with(model: comment) do |form| %>
  <%= render 'shared/form_errors', resource: comment %>
  <%= form.hidden_field :commentable_id, value: commentable.id %>
  <%= form.hidden_field :commentable_type, value: commentable.class.name %>
  <div class="field">
    <%= form.text_area :content, required: true %>
  </div>
  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

Create the 'comment' partial to display the comment and its comments

```
$ touch app/views/comments/_comment.html.erb
```

```erb
<div class='py-2 border-start border-1 ps-3 pb-0 card border-0 rounded-0 <%= cycle('', 'bg-light') %> '>
  <div class="d-flex justify-content-start">
    <%= user_avatar(comment.user, height: 30, width: 30) %>
    <div class='d-flex flex-column ms-2'>
      <%= link_to comment.user.name, comment.user, class: 'mx-1 text-decoration-none' %>
      <p class='fw-lighter small'>
        <%= distance_of_time_in_words(comment.created_at) %> ago
      </p>
    </div>
  </div>
  <%= comment.content %>
  <%= render 'comments/reply', commentable: comment %>
  <%= render comment.comments %>
</div>
```

Update styles in `main.scss`

```scss
// previous styles here ...

a.reply-link {
  max-width: min-content;
  text-decoration: none;
  font-size: 0.8rem;
}
```

Now our users can comment on answers and even on comments to answers
