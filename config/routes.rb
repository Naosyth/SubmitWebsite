Rails.application.routes.draw do
  resources :user_sessions

  get 'login' => "user_sessions#new",      :as => :login
  get 'logout' => "user_sessions#destroy", :as => :logout

  resources :users  # give us our some normal resource routes for users
  resource :dashboard

  get 'signup' => 'users#new', :as => :signup

  root :to => 'user_sessions#new'
end
