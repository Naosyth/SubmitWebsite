class TestCasesController < ApplicationController

  # Shows a test case
  def show
    @test_case = TestCase.find(params[:id])
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
