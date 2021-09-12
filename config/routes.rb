Rails.application.routes.draw do
  resources :answers
  resources :questions
  get "users/index"
  get "users/show"
  devise_for :users
  authenticate :user do
    resources :users, only: [:index, :show]
  end
  root to: "home#index"
end
