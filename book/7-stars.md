# 7 Adding Stars

In this chapter we will allow users to add stars to questions and also to answers they find very helpful.

## 7.1 Implement Stars

Generate star model

```bash
$ rails g model star user:belongs_to starrable:references{polymorphic}
```

```
$ rails db:migrate
```

Generate stars controller

```
$ rails g controller stars --skip-stylesheets
```

Add 'stars' resources in `routes.rb`

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  root to: "home#index"
  devise_for :users
  authenticate :user do
    ...
    ...
    resources :stars, only: [:create, :destroy]
  end
end
```

Add uniqueness validation to star model.

```ruby
class Star < ApplicationRecord
  belongs_to :user
  belongs_to :starrable, polymorphic: true
  validates_uniqueness_of :user, scope: [:starrable_id,
                                         :starrable_type]
end
```

This validation ensures star is unique for each user and starrable object

Add stars to question model

```ruby
class Question < ApplicationRecord
  ...
  ...
  has_many :stars, as: :starrable
end
```

Add stars to answer model

```ruby
class Answer < ApplicationRecord
  ...
  ...
  has_many :stars, as: :starrable
end
```

Add stars to users

```ruby
class User < ApplicationRecord
  ...
  ...

  has_many :stars
end
```

Implement `create` and `destroy` actions in `stars` controller. To improve the user experiences we will implement the `star` ring via ajax.

```ruby
class StarsController < ApplicationController
  def create
    @star = current_user.stars.new(stars_params)
    @star.save
    respond_to do |format|
      format.js { render "stars" }
    end
  end

  def destroy
    @star = Star.find(params[:id])
    authorize @star
    @star.destroy
    respond_to do |format|
      format.js { render "stars" }
    end
  end

  private

  def stars_params
    params.permit(:starrable_id, :starrable_type)
  end
end
```

Create the `stars.js.erb` view. In this view, we are retrieving and replacing a `stars` partial that corresponds to a given starrable.

```javascript
var stars = document.getElementById(
  '<%= j "#{@star.starrable.class.name.downcase}_#{@star.starrable.id}_stars" %>',
);
stars.innerHTML = "<%= j render('stars/stars', starrable: @star.starrable) %>";
```

Create `star` policy to prevent users from deleting others' stars

```
$ rails g pundit:policy star
```

Create the `destroy?` method in the generated `star` policy

```ruby
class StarPolicy < ApplicationPolicy
  def destroy?
    user == record.user
  end
end
```

Add `starred` method in user model, to check whether a user starred a question or an answer

```ruby
class User < ApplicationRecord
  ...
  ...

  def starred(starrable)
    Star.where(user: self, starrable: starrable).first
  end
end
```

Add `stars` to `answer` partial

`app/views/answers/_answer.html.erb`

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
      <span class="mx-2">
        &middot;
      </span>
      <%= render 'stars/stars', starrable: answer %>
    </div>
  </div>
  ...
  ...
</div>
```

Now create the stars partial

```bash
$ touch app/views/stars/_stars.html.erb
```

`_stars.html.erb`

```erb
<div class='d-inline' id=<%="#{starrable.class.name.downcase}_#{starrable.id}_stars"%>>
  <% if star=current_user.starred(starrable) %>
    <%= link_to pluralize(starrable.stars.count, 'star'), star, method: :delete, remote: true, class: 'text-decoration-none star-link' %>
  <% else %>
    <%= link_to pluralize(starrable.stars.count, 'star'), stars_path(starrable_id: starrable.id, starrable_type: starrable.class.name), method: :post, remote: true, class: 'text-decoration-none star-link' %>
  <% end %>
</div>
```

Note that our links have a `remote: true` option to signify that we are making a request via ajax and there will be no full page reload

Update `main.scss`

```scss
// previous styles here

a.reply-link,
a.star-link {
  max-width: min-content;
  text-decoration: none;
  font-size: 0.8rem;
  text-transform: lowercase;
}
```

Add the `stars` partial in questions show page as well
`_question.html.erb`

```erb
<p class='small text-muted fw-bold mb-0 pb-0'><%= question.created_at.to_s(:long) %></p>
<div class="card question-card mt-0 mb-3 border-0 bg-light border-top">
  <div class="card-body py-2">
    ...
    ...
  </div>
  <div class="card-footer">
    <%= render 'stars/stars', starrable: question %>
  </div>
</div>
```

Now you can try add stars to the questions and answers. You will notice that the `stars` count will update without a full page reload.

## 7.2 Rank Answers by Number of Stars

Add `stars_count` column to `answers` and `questions` columns

```bash
$ rails g migration add_stars_count_to_questions stars_count:bigint

$ rails g migration add_stars_count_to_answers stars_count:bigint
```

Add a default stars_count of 0 to both answers and questions

```ruby
class AddStarsCountToAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :answers, :stars_count, :bigint, default: 0
  end
end
```

```ruby
class AddStarsCountToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :questions, :stars_count, :bigint, default: 0
  end
end
```

Run migrations

```
$ rails db:migrate
```

Update `stars_count` by actual number of stars in `answers` and `questions`.

Generate the migration

```
$ rails g migration populate_stars_count_in_questions_and_answers
```

Add `up` and `down` methods to the generated migration to update the `stars_count` column by iterate over all the questions and answers and update each with the related number of stars.

`{timestamp}_populate_stars_count_in_questions_and_answers.rb`

```ruby
class PopulateStarsCountInQuestionsAndAnswers < ActiveRecord::Migration[6.1]
  def up
    Question.all.each do |question|
      question.stars_count = question.stars.count
      question.answers.each do |answer|
        answer.stars_count = answer.stars.count
        answer.save!
      end
      question.save!
    end
  end

  def down
    Question.all.each do |question|
      question.answers.each do |answer|
        answer.stars_count = 0
        answer.save!
      end
      question.stars_count = 0
      question.save!
    end
  end
end
```

```bash
$ rails db:migrate
```

Add a callback method to update `stars_count` of the starrable object whenever a `star` is created or destroyed

```ruby
class Star < ApplicationRecord
  ...
  ...

  after_save :update_stars_count
  after_destroy :update_stars_count

  def update_stars_count
    starrable.stars_count = starrable.stars.count
    starrable.save!
  end
end
```

Add a `default_scope` in answer model to order answers by `stars_count` in descending order

```ruby
class Answer < ApplicationRecord
  ...
  ...

  default_scope { order(stars_count: :desc) }
end
```
