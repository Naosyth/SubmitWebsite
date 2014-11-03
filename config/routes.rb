Rails.application.routes.draw do
  resources :user_sessions

  get 'login' => "user_sessions#new",      :as => :login
  get 'logout' => "user_sessions#destroy", :as => :logout

  resources :users

  get 'dashboard' => 'users#dashboard', :as => :dashboard
  get 'settings' => 'users#settings', :as => :settings
  patch 'settings' => 'users#update', :as => :setting
  get 'signup' => 'users#new', :as => :signup

  get 'courses/enroll' => 'courses#enroll', :as => :courses_enroll
  post 'courses/enroll' => 'courses#join'
  get 'courses/enrolled' => 'courses#enrolled', :as => :courses_enrolled
  get 'courses/:id/users' => 'courses#users', :as => :courses_users
  get '/courses/:course_id/users/:user_id' => 'courses#edit_user', :as => :course_user_edit
  patch '/courses/:course_id/users/:user_id' => 'courses#update_user'
  resources :courses

  root :to => 'user_sessions#new'
end
