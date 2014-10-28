class DashboardsController < ApplicationController
  before_filter :require_user

  def show
  	@user = current_user
    if @user.role == "admin"
    	render :action => :admin
    elsif @user.role == "teacher"
    	render :action => :teacher
    else
    	render :action => :student
    end
  end

end
