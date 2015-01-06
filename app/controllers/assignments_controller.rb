class AssignmentsController < ApplicationController
  include AssignmentsHelper

  before_filter :require_user
  before_filter :require_instructor_owner, :only => [:new, :create, :copy, :destroy]
  before_filter :require_enrolled, :only => [:show]

  # Creates the form to make a new assignment
  def new
    @assignment = Assignment.new
    @course = Course.find(params[:course_id])
  end

  # Creates a new assignment. Redirects to the course page the assignment belongs to on success.
  def create
    @course = Course.find(params[:course_id])

    convert_dates_to_utc
    @assignment = @course.assignments.new(assignment_params)
    if @assignment.save
      @assignment.create_submissions_for_students
      @assignment.create_test_case
      redirect_to course_path(@course)
    else
      render :action => :new
    end
  end

  # Copys over an old assignment
  def copy
    @course = Course.find(params[:course_id])
  end

  # Saves the selected assignment to copy over
  def copy_create
    assignment_old = Assignment.find(params[:old_assignment_id])
    course = Course.find(params[:course_id])
    assignment = course.assignments.new
    assignment.name = assignment_old.name
    assignment.description = assignment_old.description
    assignment.due_date = assignment_old.due_date
    assignment.start_date = assignment_old.start_date
    if assignment.save
      @test = assignment.test_case
      @old_test = assignment_old.test_case
      copy_files
      redirect_to edit_assignment_path(assignment)
    else
      flash[:notice] = "Could not copy Assignment"
      redirect_to course_path(assignment.course)
    end
  end

  # Displays an assignment
  def show
    @assignment = Assignment.find(params[:id])
    @course = @assignment.course
    @submissions = @assignment.submissions

    if current_user.has_local_role? :instructor, @course
      @test_case = @assignment.test_case 
      render "assignments/manage"
    end
  end

  # Creates the form to modify an assignment
  def edit
    @assignment = Assignment.find(params[:id])
    @course = @assignment.course
  end

  # Updates an assignment
  def update
    @assignment = Assignment.find(params[:id])
    @course = @assignment.course

    convert_dates_to_utc
    if @assignment.update_attributes(assignment_params)
      flash[:notice] = "Assignment updated!"
      redirect_to course_path(@assignment.course)
    else
      render :action => :edit
    end
  end

  # Deletes an assignment
  def destroy
    @assignment = Assignment.find(params[:id])
    flash[:notice] = "Successfully deleted Assignment " + @assignment.name
    @assignment.destroy
    redirect_to :back
  end

  private
  def assignment_params
    params.require(:assignment).permit(:name, :total_grade, :description, :start_date, :due_date, :lock)
  end

  def convert_dates_to_utc
    params[:assignment][:start_date] = Time.at(params[:assignment][:start_date].to_i)
    params[:assignment][:due_date] = Time.at(params[:assignment][:due_date].to_i)
  end

  def copy_files
    @old_test.upload_data.each do |file|
      upload = @test.upload_data.new()
      upload.make_file(file.name, file.contents, file.file_type)
      upload.save
    end
  end
end
