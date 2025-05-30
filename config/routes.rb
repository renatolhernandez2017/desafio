Rails.application.routes.draw do
  root to: "home#index"

  devise_for :users

  get "up", to: "rails/health#show", as: :rails_health_check

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount ActionCable.server => "/cable"

  namespace :api, defaults: {format: :json} do
    resources :users, only: %i[create]
    resources :messages, only: %i[index create update destroy]

    post "/unlock/:token", to: "sessions#unlock", as: :unlock
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
  end
end
