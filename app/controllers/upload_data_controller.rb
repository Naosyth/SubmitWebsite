class UploadDataController < ApplicationController
  before_filter :require_user
  before_filter :require_data_owner, :only => [:reupload, :edit, :upload_data, :destroy]
  before_filter :require_submission_owner, :only => [:create]
  before_filter :require_instructor_owner, :only => [:show]

  # Creates a new upload data
  def create
    @submission = Submission.find(params[:submission_id])

    if params[:upload_file].blank? 
      flash[:notice] = "No File Selected"
      redirect_to submission_url(@submission) and return
    end

    @upload_data = @submission.upload_data.create
    @upload_data.create_file(params[:upload_file])

    if @upload_data.save
      flash[:notice] = "File Loaded"
    else
      flash[:notice] = "File Not Loaded"
    end
    redirect_to submission_url(@submission)
  end

  def reupload
    upload_data = UploadDatum.find(params[:id])

    if params[:upload_file].blank? 
      flash[:notice] = "No File Selected"
      redirect_to submission_url(upload_data.submission) and return
    end

    upload_data.create_file(params[:upload_file])

    if upload_data.save
      flash[:notice] = "File Changed"
    else
      flash[:notice] = "File Not Changed"
    end
    redirect_to submission_url(upload_data.submission)
  end

  # Shows an upload data
  def show
    @upload_data = UploadDatum.find(params[:id])
    if @upload_data.file_type == 'application/pdf'
      send_data @upload_data.contents, type: 'application/pdf', filename: @upload_data.name, disposition: 'inline'
    elsif @upload_data.file_type.include? "text"
      render :action => :show
    else
      flash[:notice] = "Cannot Display that file type."
      redirect_to :back
    end
  end

  # Edits an existing upload data
  def edit
    @upload_data = UploadDatum.find(params[:id])
  end

  # Updates an upload data
  def update
    upload_data = UploadDatum.find(params[:id])
    if upload_data.update_attributes(upload_data_params)
      flash[:notice] = "File Updated"
      redirect_to submission_url(upload_data.submission)
    end
  end

  # Removes the file
  def destroy
    @upload_data = UploadDatum.find(params[:id])
    @upload_data.destroy
    flash[:notice] = "File successfully deleted"
    redirect_to :back
  end

  private
  def upload_data_params
    params.require(:upload_datum).permit(:name, :contents, :file_type)
  end

  def require_data_owner
    upload_data = UploadDatum.find(params[:id])

    if current_user != upload_data.submission.user
      flash[:notice] = "That action is only available to the file owner"
      redirect_to dashboard_url
    end
  end

  def require_submission_owner
    submission = Submission.find(params[:submission_id])

    if current_user != submission.user
      flash[:notice] = "That action is only available to the submission owner"
      redirect_to dashboard_url
    end
  end

  def require_instructor_owner
    return if current_user.has_role? :admin

    upload_data = UploadDatum.find(params[:id])
    course = upload_data.submission.assignment.course
    if not(current_user.has_role? :instructor, course) && current_user != upload_data.submission.user
      flash[:notice] = "That action is only available to the instructor or file owner"
      redirect_to dashboard_url
    end
  end

end
