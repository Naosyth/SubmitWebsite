class CoursesController < ApplicationController
  include CoursesHelper

  before_filter :require_user
  before_filter :require_student, :only => [:enrolled]
  before_filter :require_student_enrolled, :only => [:show]
  before_filter :require_instructor_owner, :only => [:edit, :edit_user, :users, :update, :update_user, :destroy]
  before_filter :require_instructor, :only => [:new, :create, :taught]
  before_filter :require_admin, :only => [:index]
  
  # Creates the form for creating a new course.
  def new
    @course = Course.new
  end

  # Creates a new course.
  # Redirects to the course's show page on success.
  def create
    @course = Course.new(course_params)

    @course.join_token = SecureRandom.base64(8)

    if current_user.has_role? :instructor
      current_user.courses << @course
      current_user.add_role :instructor, @course
    end

    if @course.save
      flash[:notice] = "Course created successfully."
      redirect_to @course
    else
      flash[:notice] = "Error creating course."
      render :action => :new
    end
  end

  # Displays basic information about the course.
  def show
    @course = Course.find(params[:id])
    @assignments = @course.assignments.select { |assignment| Time.now > assignment.start_date }
  end

  # Displays a list of all courses in the application.
  def index
    @courses = Course.all
  end

  # Displays all users enrolled in a specific course.
  def enrolled
    @course = Course.new
    @courses = current_user.courses
  end

  # Creates the form for editing an existing course.
  def edit
    @course = Course.find(params[:id])
  end

  # Applies changes to a course when it is edited.
  def update
    @course = Course.find(params[:id])

    if @course.update_attributes(course_params)
      flash[:notice] = "Course updated!"
      redirect_to courses_url
    end
  end

  # Creates the form for enrolling in a course.
  def enroll
    @course = Course.new
  end

  # Creates a link between a user and the course.
  # Applies the default student role to the user.
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

  # List all users in a specific course.
  def users
    @course = Course.find(params[:id])
    @users = @course.users.all
  end

  # Creates the form for editing a user in the scope of a course.
  def edit_user
    @course = Course.find(params[:course_id])
    @user = User.find(params[:user_id])
  end

  # Applies changes to a user in the scope of a specific course.
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

  # Kicks a user out of a course.
  def kick_user
    @course = Course.find(params[:course_id])
    @user = User.find(params[:user_id])

    User::ROLES.each do |role|
      @user.remove_role role, @course
    end
    @course.users.delete(@user)

    flash[:notice] = "User has been kicked from the course."
    redirect_to :back
  end

  # Displays all courses an instructor teaches.
  def taught
    @user = current_user
    @courses = current_user.courses.select { |course| current_user.has_local_role? :instructor, course }
  end

  # Deletes a course.
  # Removes all roles in the scope of the course from any enrolled users.
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
  def course_params
    params.require(:course).permit(:name, :description, :term, :year, :open, :join_token)
  end
end
