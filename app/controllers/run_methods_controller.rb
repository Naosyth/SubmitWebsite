class RunMethodsController < ApplicationController

  # create new
  def new
    @run_method = RunMethod.new
    @test_case = TestCase.find(params[:test_case_id])
  end

  # create
  def create
    test_case = TestCase.find(params[:test_case_id])
    run_method = test_case.run_methods.new(run_method_params)

    if run_method.save 
      redirect_to test_case_url(test_case)
    else
      render :action => :new
    end
  end

  # edit
  def edit
  end

  # show
  def show
    @run_method = RunMethod.find(params[:id])
  end

  # update
  def update
  end

  # DELETE
  def destroy
    @run_method.destroy
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def run_method_params
      params.require(:run_method).permit(:name, :run_command, :description)
    end
end
