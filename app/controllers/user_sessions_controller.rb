class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:destroy, :forgot_password, :change_password]

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to dashboard_url
      return false
    end
  end

  def new
    @user_session = UserSession.new

    render layout: "authentication"
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default dashboard_url(@current_user)
    else
      render :layout => "authentication", :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end

  def forgot_password
    @user_session = current_user_session

    render layout: "authentication"
  end

  def change_password
    @user = current_user
    if @user.valid_password?(params[:user_session][:old_password])
      @user.password = params[:user_session][:password]
      @user.password_confirmation = params[:user_session][:password_confirmation]
      if @user.changed? and @user.save
        redirect_to dashboard_url(@current_user)
      else
        @user_session = @user
        render :layout => "authentication", :action => :forgot_password
      end
    else
      @user.errors.add(:Confirmation, 'Incorrect Old Password')
      @user_session = @user
      render :layout => "authentication", :action => :forgot_password
    end
  end
end
