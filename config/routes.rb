Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  namespace :admin do
  end

  ###############
  ###   API  ###
  ###############

  namespace :api do
  end
end
