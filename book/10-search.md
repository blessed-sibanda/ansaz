# 10 Searching for Questions

Our users can now join groups and ask questions in those groups. In this chapter we will implement a question search feature.

This search feature will allow users to find questions based on title, content and tags.

# 10.1 Implement Search UI

Create a new controller

```
$ rails g controller search index
```

Update routes

```ruby
Rails.application.routes.draw do
  get "search/index"
  get "tags/index"
  root to: "home#index"
  devise_for :users
  authenticate :user do
    ...
    ...
    resources :search, only: :index
  end
end
```

Change the navbar search form to a search link

`app/views/layouts/_navbar.html.erb`

```erb
<nav class="navbar navbar-expand-lg navbar-light bg-light sticky-top">
  <div class="container">
    <%= link_to content_tag(:strong, 'Ansaz'), root_path, class: 'navbar-brand' %>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" >
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item">
          <%= link_to 'Users', users_path, class: 'nav-link' %>
        </li>
        <li class="nav-item">
          <%= link_to 'Search', search_index_path, class: 'nav-link' %>
        </li>
        <% if user_signed_in? %>
          ...
          ...
        <% end %>
      </ul>
    </div>
  </div>
</nav>
```

Next lets create the search form in search `index` page

`app/views/search/index.html.erb`

```erb

```

Search service

Pagination

Update Tag controller
