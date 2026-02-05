Rails.application.routes.draw do
  resources :users, only: [:index]
  resources :inquiries, only: [:index]

  root "users#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
