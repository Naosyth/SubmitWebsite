class CoursesController < ApplicationController
  before_filter :require_user
  before_filter :require_enrolled, :only => [:show]
  
  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)

    @course.join_token = SecureRandom.base64(8)

    if @course.save
      flash[:notice] = "Course created successfully."
      redirect_to @course
    else
      flash[:notice] = "Error creating course."
      render :action => :new
    end
  end

  def show
    @course = Course.find(params[:id])
  end

  def index
    if not current_user.has_role? :admin
      redirect_to dashboard_url
    end

    @courses = Course.all
  end

  def enrolled
    @course = Course.new
    @courses = current_user.courses
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])

    if @course.update_attributes(course_params)
      flash[:notice] = "Account updated!"
      redirect_to :back
    end
  end

  def enroll
    @course = Course.new
  end

  def join
    @course = Course.where(join_token: params[:course][:join_token]).first

    if @course and not current_user.courses.include? @course
      current_user.courses << @course
      current_user.add_role :student, @course
      flash[:notice] = "Successfully joined class"
      redirect_to course_path(@course.id)
    else
      flash[:notice] = "Failed to join class"
      redirect_to :back
    end
  end

  def users
    @course = Course.find(params[:id])
    @users = @course.users.all
  end

  def edit_user
    @course = Course.find(params[:course_id])
    @user = User.find(params[:user_id])
  end

  def update_user
    @course = Course.find(params[:course_id])
    @user = User.find(params[:user_id])

    User::ROLES.each do |role|
      if params[:user][:roles].include? role
        @user.add_role role, @course
      else
        @user.remove_role role, @course
      end
    end

    flash[:notice] = "User has been updated."
    redirect_to :back
  end

  def destroy
    @course = Course.find(params[:id])

    @course.users.each do |user|
      User::ROLES.each do |role|
        user.remove_role role, @course
      end
    end

    @course.destroy
    flash[:notice] = "Course successfully deleted"

    redirect_to :back
  end

  private
  def require_enrolled
    course = Course.find(params[:id])
    if not course.users.include? current_user and not current_user.has_role? :admin
      flash[:notice] = "You may only view courses you are enrolled in"
      redirect_to dashboard_url
    end
  end

  def course_params
    params.require(:course).permit(:name, :description, :term, :year, :open, :join_token)
  end
end
