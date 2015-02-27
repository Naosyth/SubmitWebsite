class CommentsController < ApplicationController
  # Creates a new comment
  def create
    @upload_datum = UploadDatum.find(params[:upload_id])
    @comment = @upload_datum.comments.new(comment_params)
    @comments = @upload_datum.comments

    if @comment.save
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
    @comments = @comment.upload_datum.comments
    @comment.destroy

    respond_to do |format|
      format.js { render :action => "refresh" }
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:contents, :line)
  end
end
