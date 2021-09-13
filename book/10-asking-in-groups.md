# 10 Asking in Groups

In this chapter we will allow our users to ask question in groups and get answers from other group members.

# 10.1 Link Questions To Groups

```
$ rails g migration add_group_to_questions group:references
```

Allow `null` in `group_id`

```ruby
class AddGroupToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_reference :questions, :group, null: true, foreign_key: true
  end
end
```

```bash
$ rails db:migrate
```

Add optional group to question model

```ruby
class Question < ApplicationRecord
  ...
  ...
  belongs_to :group, optional: true
end
```

Add questions to group

```ruby
class Group < ApplicationRecord
  ...
  ...
  has_many :questions

  ...
end
```

Add a link to ask questions in group `show` page

```erb
<div class="card rounded-0">
  <%= image_tag @group.banner, class: 'card-img-top rounded-0 group-banner' %>
  <div class="card-body">
    <div class="d-flex justify-content-between">
      <h3><%= @group.name %></h3>
      <div><%= render 'ask', group: @group %></div>
    </div>
    <div class="card-text"><%= @group.description %></div>
  </div>
</div>
<%= content_for :sidebar do %>
  <%= render 'sidebar', group: @group %>
<% end %>
```

Create the ask partial

```
$ touch app/views/groups/_ask.html.erb
```

```erb
<% if policy(group).participate? %>
  <% modal_id = "modal_#{SecureRandom.hex(4)}" %>
  <%= render 'shared/modal', id: modal_id, title: group.name do %>
    <h3>New Question</h3>
    <%= render 'questions/form', question: group.questions.new %>
  <% end %>
  <a class='btn btn-primary' href="#" data-bs-toggle="modal" data-bs-target='#<%= modal_id %>'>
    Ask Question
  </a>
<% end %>
```

The `ask` partial checks whether the user is authorized to ask a question in the group (i.e whether the user is authorized to participate in the group) and renders the question form.

Add the `participate?` method in group policy.

```ruby
class GroupPolicy < ApplicationPolicy
  ...
  ...

  def participate?
    record.active_users.include? user
  end
end
```

Add the `active_users` method in group model

```ruby
class Group < ApplicationRecord
  ...
  ...
  has_many :active_users, -> { GroupMembership.accepted },
           through: :group_memberships, source: :user
end
```

Update the question `form` with a hidden `group_id` field

`app/views/questions/_form.html.erb`

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
  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

Update `question_params` to accept `group_id` in questions controller

```ruby
class QuestionsController < ApplicationController
  ...

  def index
    @questions = Question.ungrouped.order(created_at: :desc)
  end

  def create
    @question = current_user.questions.build(question_params)
    authorize(@question.group, :participate?) if @question.group

    respond_to do |format|
      ...
      ...
    end
  end

  private
  ...

  def set_question
    @question = Question.find(params[:id])
    authorize(@question.group, :participate?) if @question.group
  end

  def question_params
    params.require(:question).permit(:title, :content, :group_id)
  end
end
```

Add a `public` scope in `question` model to retrieve questions without groups.

```ruby
class Question < ApplicationRecord
  ...
  scope :ungrouped, -> { where(group_id: nil) }
end
```

Update group `show` page to display questions in group

```erb
<div class="card rounded-0">
  ...
</div>
<br>
<% if policy(@group).participate? %>
  <h1 class='h5 text-uppercase'>Questions</h1>
  <%= render @group.questions.select(&:persisted?) %>
<% else %>
  <div class="card bg-light p-3 rounded-0">
    <h5 class='text-danger'>The questions in this group can only be seen by the group members</h5>
    <p class='my-0'>Join the group to view the questions and participate</p>
  </div>
<% end %>
<%= content_for :sidebar do %>
  <%= render 'sidebar', group: @group %>
<% end %>
```
