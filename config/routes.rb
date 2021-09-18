Rails.application.routes.draw do
  get "search/index"
  get "tags/index"
  root to: "home#index"
  devise_for :users
  authenticate :user do
    resources :users, only: [:index, :show]
    resources :questions do
      resources :answers, only: [:create, :destroy]
    end
    resources :comments, only: [:create, :destroy]
    resources :stars, only: [:create, :destroy]
    resources :answer_acceptance, only: [:update, :destroy]
    resources :groups
    resources :group_memberships, only: [:update, :destroy] do
      member do
        post :accept
        delete :reject
      end
    end
    resources :tags, only: [:index, :show]
    resources :search, only: :index
  end
end
