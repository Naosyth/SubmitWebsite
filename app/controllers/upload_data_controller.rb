class UploadDataController < ApplicationController
  before_filter :require_user
  before_filter :require_data_owner, :only => [:reupload, :edit, :upload_data, :destroy]
  before_filter :require_destination_owner, :only => [:create]
  before_filter :require_instructor_owner, :only => [:show]

  # Creates a new upload data
  def create
    if (params[:type] == "submission")
      destination = Submission.find(params[:destination_id])
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
    @upload_data = UploadDatum.find(params[:id])
    @can_edit = false
    @comment = Comment.new
    @all_comments = get_all_comments(@upload_data.source.assignment).sort_by {|_key, value| value }.reverse
    if @upload_data.file_type == 'application/pdf'
      send_data @upload_data.contents, type: 'application/pdf', filename: @upload_data.name, disposition: 'inline'
    elsif @upload_data.file_type.include? "text"
      render :action => :show
    elsif @upload_data.file_type.include? "application"
      render :action => :show
    else
      flash[:notice] = "Cannot Display that file type."
      redirect_to :back
    end
  end

  # Edits an existing upload data
  def edit
    @upload_data = UploadDatum.find(params[:id])
    @comment = Comment.new
    @can_edit = (current_user.has_local_role? :instructor, @upload_data.source.assignment.course) ||
                (@upload_data.submission.user == current_user;)
    @all_comments = get_all_comments(@upload_data.source.assignment).sort_by {|_key, value| value }.reverse
    if not @can_edit
      render "upload_data/show"
    else
      render "upload_data/edit"
    end 

  end

  # Updates an upload data
  def update
    upload_data = UploadDatum.find(params[:id])
    if upload_data.update_attributes(upload_data_params)
      flash[:notice] = "File Updated"
      redirect_to upload_data.source
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
    if not(current_user.has_role? :instructor, course) && current_user != upload_data.submission.user
      flash[:notice] = "That action is only available to the instructor or file owner"
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
