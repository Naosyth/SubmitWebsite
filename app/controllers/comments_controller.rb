class CommentsController < ApplicationController
  # Creates a new comment
  def create
    @upload_datum = UploadDatum.find(params[:upload_id])
    @comment = @upload_datum.comments.new(comment_params)
    @file_comments = @upload_datum.comments
    @all_comments = @upload_datum.submission.assignment.get_all_comments.sort_by { |_key, value| value }.reverse

    if @comment.save
      @file_comments = @upload_datum.comments
      @all_comments = @upload_datum.submission.assignment.get_all_comments.sort_by { |_key, value| value }.reverse

      respond_to do |format|
        format.js { render :action => "refresh" }
      end
    else
      respond_to do |format|
        format.js { render :action => "error" }
      end
    end
  end

  # Shows a comment
  def show
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    @file_comments = @comment.upload_datum.comments
    @all_comments = @comment.upload_datum.submission.assignment.get_all_comments.sort_by { |_key, value| value }.reverse

    respond_to do |format|
      format.js { render :action => "refresh" }
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:contents, :line)
  end
end
