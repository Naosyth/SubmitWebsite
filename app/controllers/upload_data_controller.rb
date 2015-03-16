class UploadDataController < ApplicationController
  before_filter :require_user
  before_filter :require_data_owner, :only => [:reupload, :edit, :upload_data, :destroy]
  before_filter :require_destination_owner, :only => [:create]
  before_filter :require_instructor_owner, :only => [:show]
  before_filter :require_not_submitted, :only => [:update]

  # Creates a new upload data
  def create
    if (params[:type] == "submission")
      destination = Submission.find(params[:destination_id])
      destination.remove_saved_runs
    elsif (params[:type] == "test_case")
      destination = TestCase.find(params[:destination_id])
    end

    if params[:upload_file].blank? 
      flash[:notice] = "No File Selected"
      redirect_to destination and return
    end

    upload_data = destination.upload_data.select { |upload| upload.name == params[:upload_file].original_filename }.first
    upload_data = destination.upload_data.create if upload_data.nil?
    upload_data.create_file(params[:upload_file])

    if upload_data.save
      flash[:notice] = "File Loaded"
    else
      flash[:notice] = "File Not Loaded"
    end
    redirect_to destination
  end

  # Shows an upload data
  def show
    @upload_datum = UploadDatum.find(params[:id])
    @new_comment = Comment.new
    source = @upload_datum.source
    course = @upload_datum.source.assignment.course

    if source.class.name == "TestCase"
      @can_edit = true
      render "upload_data/edit_no_comments" and return
    end

    submission = @upload_datum.submission
    file_type = @upload_datum.file_type
    @can_edit = (submission.user == current_user and not submission.submitted)
    @can_comment = current_user.has_local_role? :grader, course
    @all_comments = get_all_comments(submission.assignment).sort_by { |_key, value| value }.reverse
    @file_comments = @upload_datum.comments

    if file_type == 'application/pdf'
      send_data @upload_datum.contents, type: 'application/pdf', filename: @upload_datum.name, disposition: 'inline' and return
    elsif file_type.include? "text" or file_type.include? "application"
      if current_user.has_local_role? :grader, course
        render "upload_data/edit_grader" and return
      elsif current_user.has_local_role? :student, course
        render "upload_data/edit_student" and return
      end
    else
      flash[:notice] = "Cannot display that file type."
      redirect_to :back and return
    end
  end

  # Updates an upload data
  def update
    upload_data = UploadDatum.find(params[:id])
    source = upload_data.source

    if upload_data.update_attributes(upload_data_params)
      respond_to do |format|
        format.js { render :action => "refresh" }
      end

      if source.class.name == "Submission"
        source.remove_saved_runs
      else
        source.assignment.remove_saved_runs
      end
    end
  end

  # Removes the file
  def destroy
    @upload_data = UploadDatum.find(params[:id])
    @upload_data.destroy
    source = @upload_data.source
    if source.class.name == "Submission"
      redirect_to upload_datum_url(@upload_data) if @upload_data.submission.submitted
      source.remove_saved_runs
    end
    flash[:notice] = "File successfully deleted"
    redirect_to :back
  end

  private
  def upload_data_params
    params.require(:upload_datum).permit(:name, :contents, :file_type)
  end

  def require_data_owner
    upload_data = UploadDatum.find(params[:id])
    source = upload_data.source

    if source.class.name == "TestCase"
      if not current_user.has_local_role? :instructor, source.assignment.course
        flash[:notice] = "Only the course instructor may edit test cases"
        redirect_to dashboard_url
      end
    elsif current_user != source.user
      flash[:notice] = "That action is only available to the file owner"
      redirect_to dashboard_url
    end
  end

  def require_destination_owner
    if (params[:type] == "submission")
      destination = Submission.find(params[:destination_id])
      if current_user != destination.user
        flash[:notice] = "That action is only available to the submission owner"
        redirect_to dashboard_url
      end
    elsif (params[:type] == "test_case")
      destination = TestCase.find(params[:destination_id])
      if current_user.has_local_role? :instructor, destination.assignment
        flash[:notice] = "That action is only available to the course instructor"
        redirect_to dashboard_url
      end
    end
  end

  def require_instructor_owner
    return if current_user.has_role? :admin

    upload_data = UploadDatum.find(params[:id])
    course = upload_data.source.assignment.course
    if upload_data.source.class.name == "TestCase" and not (current_user.has_role? :grader, course)
      flash[:notice] = "Only graders and instructors may edit test cases"
      redirect_to dashboard_url
    elsif upload_data.source.class.name == "Submission" and (not (current_user.has_role? :grader, course) and current_user != upload_data.submission.user)
      flash[:notice] = "That action is only available to graders or the file owner"
      redirect_to dashboard_url
    end
  end

  def require_not_submitted
    upload_data = UploadDatum.find(params[:id])
    return if upload_data.source.class.name == "TestCase"

    if upload_data.source.submitted
      flash[:notice] = "You may not edit files after submitting your assignment"
      redirect_to dashboard_url
    end
  end

  def get_all_comments(assignment)
    comments = Hash.new
    assignment.submissions.each do |s| 
      s.upload_data.each do |u|
        u.comments.each do |c|
          if comments[c.contents] == nil
            comments[c.contents] = 0
          end
          comments[c.contents] += 1
        end
      end 
    end
    return comments
  end
end
