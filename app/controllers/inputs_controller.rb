class InputsController < ApplicationController
  
  # show
  def show
  end

  # create new
  def new
    @input = Input.new
  end

  # Update
  def update
  end

  # DELETE 
  def destroy
    @input.destroy
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def input_params
      params.require(:input).permit(:name, :description, :data, :student_visible, :run_method_id)
    end
end
