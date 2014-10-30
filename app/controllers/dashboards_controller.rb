class DashboardsController < ApplicationController
  before_filter :require_user

  def show
    @user = current_user
    if @user.has_role? :admin
    	render :action => :admin
    elsif @user.has_role? :instructor
    	render :action => :teacher
    elsif @user.has_role? :student
    	render :action => :student 
    end  	
  end

end
