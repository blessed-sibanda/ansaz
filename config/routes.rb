Rails.application.routes.draw do
  root to: 'home#index'
  devise_for :users
  authenticate :user do
    resources :users, only: %i[index show]
    resources :questions do
      resources :answers, only: %i[create destroy]
    end
    resources :comments, only: %i[create destroy]
    resources :stars, only: %i[create destroy]
    resources :answer_acceptance, only: %i[update destroy]
    resources :groups
    resources :group_memberships, only: %i[update destroy] do
      member do
        post :accept
        delete :reject
      end
    end
    resources :tags, only: %i[index show]
    resources :search, only: :index
  end
end
