class AssignmentsController < ApplicationController

  def new
    @assignment = Assignment.new
    @course = Course.find(params[:course_id])
  end

  def create
    @course = Course.find(params[:assignment][:course_id])
    render :action => :old
  end

end
