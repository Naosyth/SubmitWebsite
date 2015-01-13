class TestCasesController < ApplicationController

  # Shows a test case
  def show
    @test_case = TestCase.find(params[:id])
  end

  # Create the output files
  def create_output
    test_case = TestCase.find(params[:id])
    tempDirectory = Rails.configuration.compile_directory + current_user.name + '_' + test_case.id.to_s + '/'
    if not Dir.exists?(tempDirectory) 
      Dir.mkdir(tempDirectory)
    end

    # Adds in the test case files
    test_case.create_directory(tempDirectory)

    # Compiles and runs the program
    comp_status = test_case.compile_code(tempDirectory)

    if comp_status.nil?
      flash[:notice] = "Outputs Made"
    else
      flash[:notice] = "No Outputs Made"
      flash[:comperr] = comp_status
    end

    FileUtils.rm_rf(tempDirectory)
    redirect_to :back
  end
  
  private
    # Gets the course this test case belongs to
    def get_course
	    return TestCase.find(params[:id]).assignment.course
    end
    helper_method :get_course
  
    # Gets the course this test case belongs to
    def get_assignment
      return TestCase.find(params[:id]).assignment
    end
    helper_method :get_assignment
end
