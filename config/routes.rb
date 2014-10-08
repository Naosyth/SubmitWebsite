Rails.application.routes.draw do
  resources :user_sessions

  get 'login' => "user_sessions#new",      :as => :login
  get 'logout' => "user_sessions#destroy", :as => :logout

  resources :users  # give us our some normal resource routes for users
  resource :user, :as => 'account'  # a convenience route

  get 'signup' => 'users#new', :as => :signup

  root :to => 'users#new'
end
