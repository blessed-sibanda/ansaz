Rails.application.routes.draw do
  root to: "home#index"
  devise_for :users
  authenticate :user do
    resources :users, only: [:index, :show]
    resources :questions do
      resources :answers
    end
    resources :comments
    resources :stars, only: [:create, :destroy]
    resources :answer_acceptance, only: [:update, :destroy]
    resources :groups
  end
end
