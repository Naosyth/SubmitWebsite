class SubmissionsController < ApplicationController
  before_filter :require_user
  before_filter :require_owner, :only => [:show]
  before_filter :require_instructor_owner, :only => [:index]

  # Shows a submission
  def show
    @submission = Submission.find(params[:id])
  end

  # Creates form to set a note or manually enter a grade
  def edit
    @submission = Submission.find(params[:id])
  end

  # Updates an existing submission
  def update
    submission = Submission.find(params[:id])

    if submission.update_attributes(submission_params)
      flash[:notice] = "Submission updated!"
      redirect_to assignment_url(get_assignment)
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
