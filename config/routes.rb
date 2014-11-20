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
  get 'courses/taught' => 'courses#taught', :as => :courses_taught
  get 'courses/:id/users' => 'courses#users', :as => :courses_users
  get '/courses/:course_id/users/:user_id' => 'courses#edit_user', :as => :course_user_edit
  patch '/courses/:course_id/users/:user_id' => 'courses#update_user'
  get 'course/:course_id/users/:user_id/kick' => 'courses#kick_user', :as => :course_user_kick
  resources :courses

  get 'assignments/new/:course_id' => 'assignments#new', :as => :new_assignment
  post 'assignments/new/:course_id' => 'assignments#create'
  resources :assignments

  get 'submissions/compile/:id' => 'submissions#compile'
  resources :submissions

  post '/upload_data/test_case/:test_case_id' => 'upload_data#upload_test_case', :as => :upload_test_case
  patch '/upload_data/test_case/:id/reupload' => 'upload_data#reupload_test_case', :as => :reupload_test_case
  post '/upload_data/submission/:submission_id' => 'upload_data#upload_submission', :as => :upload_submission
  patch '/upload_data/submission/:id/reupload' => 'upload_data#reupload_submission', :as => :reupload_submission
  resources :upload_data

  resources :test_cases
  
  root :to => 'user_sessions#new'
end
