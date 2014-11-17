class UploadDataController < ApplicationController

  # Creates a new upload data
  def create
    @submission = Submission.find(params[:submission_id])
    @upload_data = @submission.upload_data.create
    @upload_data.create_file(params[:contents])

    if @upload_data.save
      flash[:notice] = "File Loaded"
    else
      flash[:notice] = "File Not Loaded"
    end
    redirect_to submission_url(@submission)
  end

  def reupload
    upload_data = UploadDatum.find(params[:id])
    upload_data.create_file(params[:contents])

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
    #send_data @upload_data.contents, type: 'application/pdf', filename: @upload_data.name, disposition: 'inline'
    send_data @upload_data.contents, type: 'text/plain', filename: @upload_data.name, disposition: 'inline'
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
    params.require(:upload_datum).permit(:name, :contents)
  end

end
