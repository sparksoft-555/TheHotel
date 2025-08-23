Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Hotel Management System routes
  root "home#index"
  get "dashboard", to: "home#dashboard"

  # Menu management
  resources :menu, except: [:destroy] do
    collection do
      get :manage
    end
    member do
      patch :toggle_availability
    end
  end

  # Order management
  resources :orders do
    member do
      patch :update_status
      patch :advance_status
    end
    collection do
      get :kitchen
    end
  end

  # Inventory management
  resources :inventory do
    member do
      patch :update_stock
    end
    collection do
      get :alerts
    end
  end

  # Employee management
  resources :work_logs, only: [ :index, :show, :create, :update ]

  # Bills and accounting
  resources :bills, only: [ :index, :show, :update ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :admin do
    root to: 'dashboard#index'
    resources :users
  end
end
