class UsersController < ApplicationController
  before_filter :require_user, :only => [:show, :dashboard, :index, :edit, :update, :settings, :change_password]
  before_filter :require_admin, :only => [:edit, :destroy]

  def require_admin
    if not current_user.has_role? :admin
      flash[:notice] = "You may not edit other accounts."
      redirect_to dashboard_url
    end
  end

  def new
    @user = User.new
    render layout: "authentication"
  end

  def create
    @user = User.new(user_params)
    @user.add_role :student

    if @user.save
      flash[:notice] = "Your account has been created."
      redirect_to dashboard_url
    else
      flash[:notice] = "There was a problem creating you."
      render :action => :new, :layout => "authentication"
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
    @user = User.find(params[:id])
  end

  def settings
    @user = current_user
  end

  def change_password
    @user = current_user
  end

  def update
    if params.has_key? :id
      @user = User.find(params[:id])
    else
      @user = current_user
    end

    if params[:user].has_key? :password
      if not current_user.valid_password? params[:user][:old_password]
        @user.errors.add(:old_password, 'was incorrect')
        render :action => :settings and return
      end
    end

    if params[:user].has_key? :roles
      User::ROLES.each do |role|
        if params[:user][:roles].include? role
          @user.add_role role 
        else
          @user.remove_role role
        end
      end
    end

    if @user.update_attributes(user_params)
      flash[:notice] = "Account updated!"
      redirect_to :back
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "User successfully deleted"

    redirect_to :back
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :commit)
  end
end
