Rails.application.routes.draw do
  get "tags/index"
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
    resources :group_memberships, only: [:update, :destroy] do
      member do
        post :accept
        delete :reject
      end
    end
    resources :tags, only: :index
  end
end
