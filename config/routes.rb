Rails.application.routes.draw do
  resources :user_sessions

  get 'login' => "user_sessions#new",      :as => :login
  get 'logout' => "user_sessions#destroy", :as => :logout

  resources :users

  get 'dashboard' => 'users#dashboard', :as => :dashboard
  get 'settings' => 'users#settings', :as => :settings
  patch 'settings' => 'users#update', :as => :setting
  get 'signup' => 'users#new', :as => :signup

  get 'courses/enroll' => 'courses#enroll'
  post 'courses/enroll' => 'courses#join'
  get 'courses/joined' => 'courses#joined'
  resources :courses

  root :to => 'user_sessions#new'
end
