class CommentsController < ApplicationController

  # Creates a new comment
  def create
    @comment = User.new(comment_params)
    if @comment.save
      flash[:notice] = "Comment has been posted"
    else
      flash[:notice] = "There was a problem creating your comment"
    end
  end

  # Shows a comment
  def show
  end

end
