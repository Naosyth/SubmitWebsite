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
    redirect_to dashboard_url unless current_user.has_role? :admin
    @course = Course.all
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

  private
  def course_params
    params.require(:course).permit(:name, :description, :term, :year, :open, :join_token)
  end
end
