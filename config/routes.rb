Rails.application.routes.draw do
  resources :stocks, only: [:index, :show]
  root to: 'stocks#index'
end
