# 10 Tagging Questions

In this chapter we will allow users to tag their questions for easier discoverability and filtering.

Generate Tag model

```
$ rails g model Tag name:uniq
```

Create a tagging model to link our tags and questions

```
$ rails g model Tagging tag:belongs_to question:belongs_to
```

Run migrations

```
$ rails db:migrate
```

Add `taggings` and `questions` to the `Tag` model

```ruby
class Tag < ApplicationRecord
  has_many :taggings
  has_many :questions, through: :taggings
end
```

Update question model with `tagging` related methods

```ruby
class Question < ApplicationRecord
  ...

  has_many :taggings
  has_many :tags, through: :taggings

  def self.tagged_with(name)
    Tag.find_by(name: name).questions
  end

  def self.tag_counts
    Tag.select("tags.*, count(taggings.tag_id) as count").joins
    (:taggings).group("taggings.tag_id")
  end

  def tag_list
    tags.map(&:map).join(", ")
  end

  def tag_list=(names)
    self.tags = names.split(",").map do |n|
      Tag.where(name: n.strip).first_or_create!
    end
  end
end
```

Update `db/seeds.rb` with a few tags

```ruby
...
...

["JavaScript", "Programming", "Ruby-on-Rails", "Science"].each do |name|
  Tag.create!(name: name)
end
```

Display question tags

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
      <input type="text" class='form-control' data-tag-target='input' data-autocomplete-target="input"/>
      <input type="hidden" name="tag_id" data-autocomplete-target="hidden"/>
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

Create the tags rails controller to give us a list of tags

```
$ rails g controller tags index --skip-stylesheets
```

```ruby
class TagsController < ApplicationController
  layout false

  def index
    @tags = Tag.all
  end
end
```

Update routes

```ruby
Rails.application.routes.draw do
  get "tags/index"
  root to: "home#index"
  devise_for :users
  authenticate :user do
    ...
    resources :tags, only: :index
  end
end
```

Create a tags stimulus controller to override the default behaviour of `stimulus-autocomplete`.

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
