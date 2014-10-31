Rails.application.routes.draw do
  resources :user_sessions

  get 'login' => "user_sessions#new",      :as => :login
  get 'logout' => "user_sessions#destroy", :as => :logout
  get 'reset' => 'user_sessions#forgot_password', :as => :reset
  patch 'change_password' => 'user_sessions#change_password', :as => :change_password

  resources :users

  get 'dashboard' => 'users#dashboard', :as => :dashboard
  get 'settings' => 'users#edit', :as => :settings

  get 'signup' => 'users#new', :as => :signup

  root :to => 'user_sessions#new'
end
