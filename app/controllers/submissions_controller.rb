class SubmissionsController < ApplicationController
  before_filter :require_user
  before_filter :require_owner, :only => [:show, :run_program]
  before_filter :require_instructor_owner, :only => [:index]

  # Shows a submission
  def show
    @submission = Submission.find(params[:id])
    @assignment = @submission.assignment
  end

  # Creates form to set a note or manually enter a grade
  def edit
    @submission = Submission.find(params[:id])
    if current_user.has_local_role? :student, get_course
      render :action => :show
    else
      @directory = @submission.create_directory 
      @comp_message = @submission.compile(@directory) 
      if @comp_message[:compile]
        flash.now[:notice] = "Compiled"
        @correct = @submission.run_test_cases(@directory, false)
      else
        flash.now[:notice] = "Not Compiled"
        flash.now[:comperr] = @comp_message[:comperr]
      end
      render :action => :edit
    end
  end

  # Updates an existing submission
  def update
    submission = Submission.find(params[:id])

    if submission.update_attributes(submission_params)
      flash[:notice] = "Submission updated!"
      redirect_to assignment_url(get_assignment)
    end
  end

  # Compiles but does not run a user's submission
  def compile
    submission = Submission.find(params[:id])
    tempDirectory = submission.create_directory
    comp_message = submission.compile(tempDirectory)

    # Check if program compiled
    if comp_message[:compile]
      flash[:notice] = "Compiled"
    else
      flash[:notice] = "Not Compiled"
      flash[:comperr] = comp_message[:comperr]
    end

    # Cleans up the files
    FileUtils.rm_rf(tempDirectory)
    redirect_to :back
  end

  # Compiles, runs the code, and creates the output files
  def run_program
    @submission = Submission.find(params[:id])
    @assignment = @submission.assignment
    @tempDirectory = @submission.create_directory

    # Compiles and runs the program
    comp_message = @submission.compile(@tempDirectory)
    if comp_message[:compile]
      flash.now[:notice] = "Compiled"
      @correct = @submission.run_test_cases(@tempDirectory, true)
    else
      flash.now[:notice] = "Not Compiled"
      flash.now[:comperr] = comp_message[:comperr]
      redirect_to :back
    end
  end

  private
    def submission_params
      params.require(:submission).permit(:grade, :note)
    end

    # Gets the course this submission belongs to
    def get_course
      return Submission.find(params[:id]).assignment.course
    end
    helper_method :get_course

    # Gets the course this submission belongs to
    def get_assignment
      return Submission.find(params[:id]).assignment
    end
    helper_method :get_assignment

    # Checks that the user is the owner of the submission, the course instructor, or an admin
    def require_owner
      submission = Submission.find(params[:id])
      return if current_user.has_role? :admin or current_user.has_local_role? :instructor, get_course

      if submission.user != current_user
        flash[:notice] = "You may only view your own submissions"
        redirect_to dashboard_url
      end
    end

    def require_instructor_owner
      return if current_user.has_role? :admin

      submission = Submission.find(params[:id])
      course = submission.assignment.course
      if not current_user.has_role? :instructor, course
        flash[:notice] = "That action is only available to the instructor of the course"
        redirect_to dashboard_url
      end
    end
end
