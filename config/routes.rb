Rails.application.routes.draw do
  root to: "home#index"

  devise_for :users

  get "/chat", to: "messages#index"

  get "up", to: "rails/health#show", as: :rails_health_check

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount ActionCable.server => '/cable'

  namespace :api, defaults: {format: :json} do
    resources :users, only: [:create]

    get "/unlock/:token", to: "sessions#unlock", as: :unlock
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
  end
end
