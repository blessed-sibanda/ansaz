# 8 Accepting Answers

In this chapter we will allow the question asker to mark answers as accepted.

# 8.1 Implement Answer Acceptances

Let's generate a controller to handle accepting answers

```bash
$ rails g controller answer-acceptance --skip-stylesheets
```

Update the routes

```ruby
Rails.application.routes.draw do
  devise_for :users
  authenticate :user do
    ...
    ...
    resources :answer_acceptance, only: [:update, :destroy]
  end
  root to: "home#index"
end
```

Create a policy to only authorize the asker of the question to mark answers as accepted.

```bash
$ rails g pundit:policy answer
```

```ruby
class AnswerPolicy < ApplicationPolicy
  def accept?
    user == record.question.user
  end
end
```

Create the `update` and `destroy` actions in the `answer-acceptance` controller

```ruby
class AnswerAcceptanceController < ApplicationController
  before_action :set_answer, only: %i[update destroy]

  def update
    @answer.accepted = true
    @answer.save
    respond_to do |format|
      format.js { render "answers/answer" }
    end
  end

  def destroy
    @answer.accepted = false
    @answer.save
    respond_to do |format|
      format.js { render "answers/answer" }
    end
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
    authorize @answer, :accept?
  end
end
```

Create the `answers` js view

```
$ touch app/views/answers/answer.js.erb
```

```javascript
var answer = document.getElementById('<%= j dom_id(@answer) %>');
answer.outerHTML = "<%= j render('answers/answer', answer: @answer) %>";
```

Update the `default_scope` in `answer` model to order answers based on acceptance status, stars_count and creation date in descending order.

```ruby
class Answer < ApplicationRecord
  ...
  ...

  default_scope {
    order(accepted: :desc)
      .order(stars_count: :desc)
      .order(created_at: :desc)
  }
end
```

Create a 'decide' partial to accept/reject an answer

```
$ touch app/views/answer_acceptance/_decide.html.erb
```

`app/views/answer_acceptance/_decide.html.erb`

```erb
<% if policy(answer).accept? %>
  <% if answer.accepted %>
    <%= link_to 'reject', answer_acceptance_path(answer), method: :delete, remote: true, class: 'text-decoration-none decide-link' %>
  <% else %>
    <%= link_to 'accept', answer_acceptance_path(answer), method: :patch, remote: true, class: 'text-decoration-none decide-link' %>
  <% end %>
<% end %>
```

Note that the `decide` partial is using `ajax` to update the answer acceptance status

This partial also uses the pundit `policy` method to check whether the current user is authorized to accept or reject in answer in question.

Update `main.scss`

```scss
// previous styles here

a.reply-link,
a.star-link,
a.decide-link,
.timestamp {
  text-decoration: none;
  font-size: 0.8rem;
  text-transform: lowercase;
}
```

Install Font-Awesome 5

```
$ yarn add @fortawesome/fontawesome-free
```

Import font-awesome in `application.js`

```javascript
...
import '@fortawesome/fontawesome-free/css/all';
```

Add the `decide` partial in the `answer` partial and also show an accepted answer with a green marking

`_answer.html.erb`

```erb
<div class="card my-3" id="<%= dom_id(answer) %>">
  <div class="card-header d-flex align-items-center justify-content-between">
    ...
    ...
  </div>
  <div class="card-body">
    <%= answer.content %>
    <div class='mt-2 text-muted'>
      <% if answer.accepted %>
        <span class="badge bg-success me-1">
          <i class="fa fa-check-circle"></i>
          <strong>Accepted</strong>
        </span>
      <% end %>
      <%= render 'comments/reply', commentable: answer %>
      <span class="mx-2">&middot;</span>
      <a class='text-decoration-none reply-link' href="#">Replies (<%= answer.comments.count %>)</a>
      <span class="mx-2">
        &middot;
      </span>
      <%= render 'stars/stars', starrable: answer %>
      <div class="float-end"><%= render 'answer_acceptance/decide', answer: answer %></div>
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
