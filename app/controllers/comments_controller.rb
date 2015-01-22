class CommentsController < ApplicationController

  # Creates a new comment
  def create
    @upload_datum=UploadDatum.find(params[:upload_id])
    @comment = @upload_datum.comments.new(comment_params)
    if @comment.save
      redirect_to :back
    else
      flash[:notice] = "Comment Failed To Upload!"
    end
  end

  # Shows a comment
  def show
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    flash[:notice] = "Comment successfully deleted"
    redirect_to :back
  end

  private
  def comment_params
    params.require(:comment).permit(:contents, :line)
  end
end
