class UsersController < ApplicationController
  before_filter :require_user, :only => [:show, :index, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.add_role :student

    if @user.save
      flash[:notice] = "Your account has been created."
      redirect_to dashboard_url(@user)
    else
      flash[:notice] = "There was a problem creating you."
      render :action => :new
    end
  end

  def show
    if params.has_key?(:id) and current_user.has_role? :admin
      @user = User.find(params[:id])
    else
      @user = current_user
    end
  end

  def index
    redirect_to dashboard_url unless current_user.has_role? :admin
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    User::ROLES.each do |role|
      if params[:user][:roles].include? role
        @user.add_role role 
      else
        @user.remove_role role
      end
    end

    if @user.update_attributes(user_params)
      flash[:notice] = "Account updated!"
      redirect_to @user
    else
      render :action => :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :commit)
  end
end
