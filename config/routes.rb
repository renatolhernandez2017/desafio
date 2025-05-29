Rails.application.routes.draw do
  root "home#index"

  devise_for :users
  get "up" => "rails/health#show", :as => :rails_health_check

  namespace :admin do
  end

  ###############
  ###   API  ###
  ###############

  namespace :api do
  end
end
