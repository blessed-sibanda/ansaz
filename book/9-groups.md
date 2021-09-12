# 9 Groups

In this chapter we will allow users to create and join groups where they can ask and answer questions on specific topics or subjects.

## 9.1 Scaffold Goups

```bash
$ rails g scaffold group name:uniq description:text admin_id:bigint group_type:integer --skip-stylesheets
```

Make `admin_id` a foreign key to `users.id`. Add a default of `0` for the group_type column.

`{timestamp}_create_groups.rb`

```ruby
class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      ...
      ...
    end
    add_index :groups, :name, unique: true
    add_foreign_key :groups, :users, column: :admin_id
  end
end
```

Run the migrations

```bash
$ rails db:migrate
```

Update the group model

- A group can either be public or private, therefore use the `inclusion` validation to validate the group type
- Add a banner image to the group as well
- Add presence validations to `name`, `description` and `banner`
- Validate the length of the group `name`

```ruby
class Group < ApplicationRecord
  belongs_to :admin, class_name: "User", foreign_key: "admin_id"
  has_one_attached :banner

  GROUP_TYPES = [
    PUBLIC = "Public",
    PRIVATE = "Private",
  ].freeze

  validates :name, :description, :banner, presence: true
  validates :name, length: { in: 5..30 }
  validates :group_type, inclusion: { in: GROUP_TYPES }
end
```

Update routes (Place the `resources: groups` inside the `authenticate :user` block)

```ruby
Rails.application.routes.draw do
  devise_for :users
  authenticate :user do
    ...
    ...
    resources :groups
  end
  root to: "home#index"
end
```

Update groups 'form'

```erb
<%= bootstrap_form_with(model: group) do |form| %>
  <%= render 'shared/form_errors', resource: group %>
  <div class="field">
    <%= form.text_field :name %>
  </div>
  <div class="field">
    <%= form.text_area :description %>
  </div>
  <div class="field">
    <%= form.file_field :banner %>
  </div>
  <div class="field">
    <%= form.select :group_type, Group.group_types.keys %>
  </div>
  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

Note we are using a select field for the drop down so that a user can select the correct group type.

Update `group_params` and `create` action in `groups-controller`

```ruby
class GroupsController < ApplicationController
  ...
  ...

  def create
    @group = Group.new(group_params)
    @group.admin = current_user

    respond_to do |format|
      ...
      ...
    end
  end

  private
  ...

  def group_params
    params.require(:group).permit(:name, :description, :group_type, :banner)
  end
end
```

## 9.2 Display Groups List

In this section, we will display the group list in the question's page sidebar.

Update the `application.html.erb` layout and make it have a two column layout

```erb
<!DOCTYPE html>
<html>
  <%= render 'layouts/head' %>
  <body>
    <%= render 'layouts/navbar' %>
    <div class="container pt-3">
      <div class="row">
        <div class="col-md-8">
          <%= render 'layouts/flash_messages' %>
          <%= yield %>
        </div>
        <div class="col-md-4">
          <%= yield :sidebar %>
        </div>
      </div>
    </div>
  </body>
</html>
```

Update questions `index` page

`app/views/questions/index.html.erb`

```erb
...
...
<%= content_for :sidebar do %>
  <div class="d-flex justify-content-between align-items-baseline mb-1">
    <h6 class='fw-bold'>Groups</h6>
    <%= link_to 'Create Group', new_group_path, class: 'btn btn-outline-primary btn-sm' %>
  </div>
  <%= render Group.all %>
<% end %>
```

Create 'group' partial

```
$ touch app/views/groups/_group.html.erb
```

`app/views/groups/_group.html.erb`

```erb
<div class="card py-0 mb-2 border-0 bg-light">
  <div class="card-body py-2 px-2">
    <div class="d-flex justify-content-between align-items-center">
      <h6 class="card-title py-0 my-0">
        <%= group_banner(group, height: 35, width: 35) %>
        <%= link_to group.name, group, class: 'text-decoration-none fw-bold' %>
      </h6>
      <%= link_to 'join', '#' %>
    </div>
    <div class='clearfix'>
      <%= truncate(group.description, length: 80) %>
    </div>
  </div>
</div>
```

Create the `group_banner` helper in `groups_helper.rb`

```ruby
module GroupsHelper
  def group_banner(group, height:, width:)
    render partial: "groups/banner_img",
           locals: { group: group,
                     height: height,
                     width: width }
  end
end
```

Create the `banner_img` partial

```
$ touch app/views/groups/_banner_img.html.erb
```

```erb
<% banner_img_url = group.banner&.variant(resize_to_limit: [height, width]) %>
<%= image_tag banner_img_url, style: "width: #{width}px; height: #{height}px; object-fit: cover;" %>
```

Update the group `show` page

`app/views/groups/show.html.erb`

```erb
<div class="card rounded-0">
  <%= image_tag @group.banner, class: 'card-img-top rounded-0 group-banner' %>
  <div class="card-body">
    <h5 class="card-title"><%= @group.name %></h1>
    <div class="card-text"><%= @group.description %></div>
  </div>
</div>
<%= content_for :sidebar do %>
  <%= render 'sidebar', group: @group %>
<% end %>
```

Create the group `sidebar` partial

```
$ touch app/views/groups/_sidebar.html.erb
```

```erb
<table class="table table-sm">
  <thead>
    <th colspan='2'>
      <span><%= group.name %></span>
      <% if policy(group).edit? %>
        <%= link_to 'Edit', edit_group_path(group), class: 'float-end' %>
      <% end %>
    </th>
  </thead>
  <tbody class="small">
    <tr>
      <th>Admin</th>
      <td><%= link_to group.admin.name, group.admin, class: 'text-decoration-none text-secondary' %></td>
    </tr>
    <tr>
      <th>Group Type</th>
      <td><%= group.group_type %></td>
    </tr>
    <tr>
      <th>Created</th>
      <td><%= group.created_at.to_s(:long) %></td>
    </tr>
  </tbody>
</table>
```

Create the group policy

```
$ rails g pundit:policy group
```

```ruby
class GroupPolicy < ApplicationPolicy
  def update?
    user == record.admin
  end

  def destroy?
    user == record.admin
  end

  def edit?
    user == record.admin
  end
end
```

Update the `groups` controller to use the `group-policy` authorizations

```
class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy ]
  before_action :check_authorization, only: %i[edit update destroy]

  ...
  ...

  private

  ...
  ...

  def check_authorization
    authorize @group
  end
end
```

Add group seed data

`db/seeds.rb`

```ruby
["Rails Devs", "Super Scientists", "Python Hackers", "Frontend Engineers", "Data Science Nerds"].each do |name|
  g = Group.new(
    name: name,
    description: Faker::Lorem.sentence(word_count: rand(50..80)),
    group_type: Group::GROUP_TYPES.sample,
    admin: User.active.sample,
  )
  g.banner.attach(
    io: File.open(Rails.root.join("app", "assets", "images", "default_banner_img.png")),
    filename: "default_banner_img.png",
  )
  g.save!
end
```

Download the `default_banner_img.png` from this books code repository

Re-seed the database

```
$ rails db:seed:replant
```

Now the questions index page looks like
![Group List Displayed in Sidebar](./questions-page-with-groups.png)

## 9.3 Link Users To Groups

Create a group-membership model

```
$ rails g model group-membership user:references group:references state
```

Update the migration to enforce only one membership for a user per group

```ruby
class CreateGroupMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :group_memberships do |t|
      ...
      ...
    end
    add_index :group_memberships, [:user_id, :group_id], unique: true
  end
end
```

```
$ rails db:migrate
```

Add validations to `group-membership` model

```ruby
class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates_uniqueness_of :user, scope: [:group_id]

  MEMBERSHIP_STATES = [
    PENDING = 'Pending',
    ACCEPTED = 'Accepted'
  ]

  validates :state, inclusion: {in: MEMBERSHIP_STATES}
end
```

- Add `group_memberships` and `owned_groups` (these are groups in which the user is an admin) to user model

```ruby
class User < ApplicationRecord
  ...
  ...

  has_many :owned_groups, class_name: "Group", foreign_key: "admin_id"
  has_many :group_memberships
  has_many :groups, through: :group_memberships, source: :group

  def starred(starrable)
    Star.where(user: self, starrable: starrable).first
  end
end
```

Add `group_memberships` and `users` to group model

```ruby
class Group < ApplicationRecord
  ...
  ...

  has_many :group_membe rships
  has_many :users, through: :group_memberships, source: :user
end
```

Create a controller to handle joining/leaving groups

```bash
$ rails g controller group-memberships --skip-stylesheets
```

Update the `routes`

```ruby
Rails.application.routes.draw do
  devise_for :users
  authenticate :user do
    ...
    ...

    resources :group_memberships, only: [:update, :destroy]
  end
  root to: "home#index"
end
```

Implement the `update` and `destroy` actions in the `group-memberships` controller

```ruby
class GroupMembershipsController < ApplicationController
  before_action :set_group, only: %i[update destroy]

  def update
    flash[:notice] = GroupMembership::Creator.call(
      user: current_user, group: @group,
    )
    redirect_back(fallback_location: root_path)
  end

  def destroy
    if current_user == @group.admin
      redirect_back(fallback_location: root_path, alert: "Group admin cannot leave")
    else
      GroupMembership.where(user: current_user,
                            group: @group).first.destroy
      redirect_to root_path, alert: "You have left '#{@group.name}' group"
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end
end
```

The `create` actions uses a service to create group-memberships. This technique allows us to move complicated logic out of the controller.

Now the let's the service

```bash
$ mkdir app/services
```

Create the base application service

```
$ touch app/services/application_service.rb
```

`application_service.rb`

```ruby
class ApplicationService
  def self.call(**args)
    new(**args).call
  end
end
```

All our services will inherit from this `ApplicationService` (Similar to how our controllers inherit from `ApplicationController`). This is good object oriented design.

The service exploses a call class-method which will be used by the service caller to run the service. Methods in a service should be private except for the `call` method only.

Now lets create the service for creating group-memberships

```bash
$ mkdir app/services/group_membership
```

Note that our services are namespaced according to the primary models they work on.

```bash
$ touch app/services/group_membership/creator.rb
```

It is good practice to name your services according to the direct action they perform. (In this case, we are 'creating' group-membership for a user, and hence our service name is `creator`)

```ruby
class GroupMembership::Creator < ApplicationService
  attr_reader :user, :group, :state, :result_message
  private :user, :group, :state, :result_message

  def initialize(user:, group:)
    @user = user
    @group = group
    set_membership_state
  end

  def call
    membership = GroupMembership.find_or_initialize_by(
      state: @state, user: @user, group: @group,
    )
    if membership.persisted?
      @result_message = "You are already in this group"
    else
      membership.save!
    end
    @result_message
  end

  private

  def set_membership_state
    if group.admin == user
      @state = GroupMembership::ACCEPTED
      return
    end
    case group.group_type
    when Group::PUBLIC
      @state = GroupMembership::ACCEPTED
      @result_message = "You have joined '#{group.name}' group"
    when Group::PRIVATE
      @state = GroupMembership::PENDING
      @result_message = "A request to join '#{group.name}' has been sent"
    end
  end
end
```

The logic is fairly straightforward. We are doing a few things:

- After initializing the class, we set the membership_state using a case statement. in the `set_membership_state` method.

- The membership state depends on the group-type being joined. If the group is public, then the membership is instant. However, if the group-type is private, the user will need to be approved by the group administrator before joining.

- The case statement is also setting the appropriate 'flash-message' that will be used in the controller to notify the user of the result of the operation.

- If the user joining the group is an admin, then the state is always ACCEPTED (i.e the admin user does not need approval from anyone to join his/her own group.

Now lets create a group partial to display groups in the questions index

Update the `group` partial with links to join/leave groups and also to show membership status