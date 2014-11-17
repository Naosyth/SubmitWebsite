class UploadDataController < ApplicationController

  # Creates a new upload data
  def create
    @submission = Submission.find(params[:submission_id])
    @upload_data = @submission.upload_data.create
    @upload_data.create_file(params[:contents])

    if @upload_data.name == nil
        @upload_data.name = "NameNotSet"
    end

    if @upload_data.save
      flash[:notice] = "File Loaded"
    else
      flash[:notice] = "File Not Loaded"
    end
    redirect_to submission_url(@submission)
  end

  # Shows an upload data
  def show
  end

  # Edits an existing upload data
  def edit
  end

  # Updates an upload data
  def update
  end

  # Removes the file
  def destroy
    @upload_data = UploadDatum.find(params[:id])
    @upload_data.destroy
    flash[:notice] = "File successfully deleted"
    redirect_to :back
  end

end
