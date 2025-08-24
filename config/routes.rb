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

  # Admin routes
  namespace :admin do
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#dashboard'
    get 'users', to: 'dashboard#users'
    get 'analytics', to: 'dashboard#analytics'
    resources :users
  end

  # Manager routes
  namespace :manager do
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#dashboard'
    get 'inventory', to: 'dashboard#inventory'
    get 'menu_management', to: 'dashboard#menu_management'
    get 'reports', to: 'dashboard#reports'
  end

  # Kitchen routes
  namespace :kitchen do
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#dashboard'
    get 'orders', to: 'dashboard#orders'
    patch 'orders/:id/status', to: 'dashboard#update_order_status', as: 'update_order_status'
    get 'orders/:id/details', to: 'dashboard#order_details', as: 'order_details'
    get 'prep_times', to: 'dashboard#prep_times'
  end

  # Cashier routes
  namespace :cashier do
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#dashboard'
    get 'billing', to: 'dashboard#billing'
    get 'orders/:id/bill', to: 'dashboard#generate_bill', as: 'generate_bill'
    patch 'orders/:id/payment', to: 'dashboard#process_payment', as: 'process_payment'
    get 'daily_report', to: 'dashboard#daily_report'
    get 'transactions', to: 'dashboard#transaction_history'
  end

  # Accountant routes
  namespace :accountant do
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#dashboard'
    get 'revenue_reports', to: 'dashboard#revenue_reports'
    get 'expense_reports', to: 'dashboard#expense_reports'
    get 'profit_loss', to: 'dashboard#profit_loss_statement'
    get 'tax_reports', to: 'dashboard#tax_reports'
    get 'inventory_valuation', to: 'dashboard#inventory_valuation'
    get 'export_data', to: 'dashboard#export_data'
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
