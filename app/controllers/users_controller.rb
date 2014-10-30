class UsersController < ApplicationController
  before_filter :require_user, :only => [:show, :dashboard, :index, :edit, :update]

  def new
    @user = User.new

    render layout: "authentication"
  end

  def create
    @user = User.new(user_params)
    @user.add_role :student

    if @user.save
      flash[:notice] = "Your account has been created."
      redirect_to user_url(@user)
    else
      flash[:notice] = "There was a problem creating you."
<<<<<<< HEAD
      render :layout => "authentication", :action => :new
=======
      render :action => :new, :layout => "authentication"
>>>>>>> 21293e994e483d30ac2a97335d7b3c4368815ee8
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def dashboard
    @user = current_user
  end

  def index
    redirect_to dashboard_url unless current_user.has_role? :admin
    @users = User.all
  end

  def edit
    return @user = current_user unless params.include? :id
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
      redirect_to user_url(@user)
    else
      render :action => :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :commit)
  end
end
