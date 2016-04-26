Rails.application.routes.draw do

  resources :lists do
    resources :subscribers
  end

  root 'lists#index'

end
