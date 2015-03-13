class InputsController < ApplicationController
  
  # create new
  def new
    @input = Input.new
    @run_method = RunMethod.find(params[:run_method_id])
  end

  # create new
  def create
    run_method = RunMethod.find(params[:run_method_id])
    input = run_method.inputs.new(input_params)

    input.name.gsub! " ", "_"

    if input.save
      redirect_to edit_run_method_url(run_method)
    else
      redirect_to :back
    end
  end

  # show
  def show
    @input = Input.find(params[:id])
  end

  # edit
  def edit
    @input = Input.find(params[:id])
  end

  # Update
  def update
    @input = Input.find(params[:id])
    #test_case = TestCase.find(@input.run_method.test_case_id)

    if @input.update_attributes(input_params)
      submissions = @input.run_method.test_case.assignment.submissions
      redirect_to test_case_url(@input.run_method.test_case_id)
    else
      render :action => :edit
    end
  end

  # DELETE 
  def destroy
    input = Input.find(params[:id])
    input.destroy
    submissions = input.run_method.test_case.assignment.submissions
    redirect_to :back
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def input_params
      params.require(:input).permit(:name, :description, :data, :student_visible)
    end
end
