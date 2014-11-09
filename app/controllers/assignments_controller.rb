class AssignmentsController < ApplicationController
  include AssignmentsHelper

  before_filter :require_user
  before_filter :require_instructor_owner, :only => [:new, :create, :destroy]
  before_filter :require_enrolled, :only => [:show]

  def new
    @assignment = Assignment.new
    @course = Course.find(params[:course_id])
  end

  def create
    @course = Course.find(params[:course_id])

    convert_dates_to_utc

    @assignment = @course.assignments.create(assignment_params)
    redirect_to course_path(@course)
  end

  def show
    @assignment = Assignment.find(params[:id])
    @course = @assignment.course
  end

  def destroy
    @assignment = Assignment.find(params[:id])
    flash[:notice] = "Successfully deleted Assignment " + @assignment.name
    @assignment.destroy
    redirect_to :back
  end

  private
  def assignment_params
    params.require(:assignment).permit(:name, :description, :start_date, :due_date, :lock)
  end

  def convert_dates_to_utc
    params[:assignment][:start_date] = Time.at(params[:assignment][:start_date].to_i)
    params[:assignment][:due_date] = Time.at(params[:assignment][:due_date].to_i)
  end
end