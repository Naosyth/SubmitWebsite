class CoursesController < ApplicationController
  before_filter :require_user
  
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

  def joined
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

  private
  def course_params
    params.require(:course).permit(:name, :description, :term, :year, :open, :join_token)
  end
end
