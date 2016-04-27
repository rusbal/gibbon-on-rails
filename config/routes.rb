Rails.application.routes.draw do

  resources :lists do
    resources :subscribers
  end

  resources :campaigns
  resources :templates

  root 'lists#index'

end
