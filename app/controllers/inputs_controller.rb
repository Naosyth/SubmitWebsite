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

    # Do not allow spaces in that name
    input.name.gsub! " ", "_"

    if input.save
      redirect_to test_case_url(run_method.test_case_id)
    else
      redirect :action => :new
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
      redirect_to test_case_url(@input.run_method.test_case_id)
    else
      render :action => :edit
    end
  end

  # DELETE 
  def destroy
    input = Input.find(params[:id])
    input.destroy
    redirect_to test_case_url(input.run_method.test_case_id)
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def input_params
      params.require(:input).permit(:name, :description, :data, :student_visible)
    end
end
