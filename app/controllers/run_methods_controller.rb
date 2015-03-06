class RunMethodsController < ApplicationController

  # create new
  def new
    flash[:notice] = "Post successfully new"
    @run_method = RunMethod.new
    @test_case = TestCase.find(params[:test_case_id])
  end

  # create
  def create
    flash[:notice] = "Post successfully created"
    @test_case = TestCase.find(params[:test_case_id])
    run_method = @test_case.run_methods.new(run_method_params)
    @run_methods = @test_case.run_methods
    
    if run_method.save 
      submissions = run_method.test_case.assignment.submissions
      submissions.each do |s|
        s.remove_cached_runs
      respond_to do |format|
        format.js { render :action => "refresh" }
      end
      redirect_to test_case_url(test_case)
    else
      respond_to do |format|
        format.js { render :action => "error" }
      end
    end
  end

  # edit
  def edit
    @run_method = RunMethod.find(params[:id])
  end

  # show
  def show
    @run_method = RunMethod.find(params[:id])
  end

  # update
  def update
    @run_method = RunMethod.find(params[:id])
    test_case = TestCase.find(@run_method.test_case_id)

    if @run_method.update_attributes(run_method_params)
      submissions = @run_method.test_case.assignment.submissions
      submissions.each do |s|
        s.remove_cached_runs
      end
      redirect_to test_case_url(test_case)
    else
      render :action => :edit
    end
  end

  # DELETE
  def destroy
    run_method = RunMethod.find(params[:id])
    test_case = TestCase.find(run_method.test_case_id)
    @run_methods = test_case.run_methods
    run_method.destroy
<<<<<<< HEAD
    submissions = run_method.test_case.assignment.submissions
    submissions.each do |s|
      s.remove_cached_runs
    end
    redirect_to test_case_url(test_case)
=======
    
    respond_to do |format|
      format.js { render :action => "refresh" }
    end
>>>>>>> Add Run Method has been Ajax-ified. As well as slight styling changes to testCases
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def run_method_params
      params.require(:run_method).permit(:name, :run_command, :description)
    end
end
