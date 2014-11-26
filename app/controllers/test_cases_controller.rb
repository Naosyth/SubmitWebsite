class TestCasesController < ApplicationController

  # Shows a test case
  def show
    @test_case = TestCase.find(params[:id])
  end

  # Create the output files
  def create_output
    test_case = TestCase.find(params[:id])
    tempDirectory = "/Users/nolanburfield/Documents/submitTest/tempDirectory/" + current_user.name + '_' + test_case.id.to_s + '/'
    if not Dir.exists?(tempDirectory) 
      Dir.mkdir(tempDirectory)
    end

    # Adds in the test case files
    test_case.upload_data.each do |upload_data|
      output = tempDirectory + upload_data.name
      f = File.open(output, "w" )
      f.write(upload_data.contents)
      f.close
    end

    # Compiles and runs the program
    make = "make -C " + tempDirectory
    if system(make)
      Dir.glob(tempDirectory + 'input_*') do |file|
        run = tempDirectory + "main < " + file
        stream = capture(:stdout) { system(run) }
        f = File.open(file.gsub("input", "output"), "w")
        f.write(stream)
        test_case.upload_data.create()
        test_case.upload_data.create_file( f )
        f.close
      end
      flash[:notice] = "Outputs Made"
    else
      stream = capture(:stderr) { system(make) }
      flash[:notice] = "No Outputs Made"
      flash[:comperr] = stream
    end
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
