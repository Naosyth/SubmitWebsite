class SubmissionsController < ApplicationController
  before_filter :require_user
  before_filter :require_owner, :only => [:show]
  before_filter :require_instructor_owner, :only => [:index]

  # Shows a submission
  def show
    @submission = Submission.find(params[:id])
  end

  # Creates form to set a note or manually enter a grade
  def edit
    @submission = Submission.find(params[:id])
    if current_user.has_local_role? :student, get_course
      render :action => :show
    else
      render :action => :edit
    end
  end

  # Updates an existing submission
  def update
    submission = Submission.find(params[:id])

    if submission.update_attributes(submission_params)
      flash[:notice] = "Submission updated!"
      redirect_to assignment_url(get_assignment)
    end
  end

  def compile
    tempDirectory = create_directory

    # Compiles and runs the program
    make = "make -C " + tempDirectory
    if system(make)
      flash[:notice] = "Compiled"
    else
      stream = capture(:stderr) { system(make) }
      flash[:notice] = "Not Compiled"
      flash[:comperr] = stream
    end

    # Cleans up the files
    FileUtils.rm_rf(tempDirectory)
    redirect_to :back
  end

  # Runs the code and creates the outputs
  def run_program
    @submission = Submission.find(params[:id])
    @tempDirectory = create_directory

    # Compiles and runs the program
    make = "make -C " + @tempDirectory
    if system(make)
      run_test_cases(@tempDirectory, @submission)
    else
      stream = capture(:stderr) { system(make) }
      flash[:notice] = "Not Compiled"
      flash[:comperr] = stream
      redirect_to :back
    end
  end

  private
    def submission_params
      params.require(:submission).permit(:grade, :note)
    end

    # Gets the course this submission belongs to
    def get_course
      return Submission.find(params[:id]).assignment.course
    end
    helper_method :get_course

    # Gets the course this submission belongs to
    def get_assignment
      return Submission.find(params[:id]).assignment
    end
    helper_method :get_assignment

    # Checks that the user is the owner of the submission, the course instructor, or an admin
    def require_owner
      submission = Submission.find(params[:id])
      return if current_user.has_role? :admin or current_user.has_local_role? :instructor, get_course

      if submission.user != current_user
        flash[:notice] = "You may only view your own submissions"
        redirect_to dashboard_url
      end
    end

    def require_instructor_owner
      return if current_user.has_role? :admin

      submission = Submission.find(params[:id])
      course = submission.assignment.course
      if not current_user.has_role? :instructor, course
        flash[:notice] = "That action is only available to the instructor of the course"
        redirect_to dashboard_url
      end
    end

    # Sets up the directory
    def create_directory
      submission = Submission.find(params[:id])

      # Creates a temporary directory for the student files
      tempDirectory = "/Users/nolanburfield/Documents/submitTest/tempDirectory/" + submission.user.name + '_' + submission.id.to_s + '/'
      if not Dir.exists?(tempDirectory) 
        Dir.mkdir(tempDirectory)
      end

      # Adds in all the student files 
      submission.upload_data.each do |upload_data|
        output = tempDirectory + upload_data.name
        f = File.open(output, "w" )
        f.write(upload_data.contents)
        f.close
      end

      # Adds in the test case files
      submission.assignment.test_case.upload_data.each do |upload_data|
        output = tempDirectory + upload_data.name
        f = File.open(output, "w" )
        f.write(upload_data.contents)
        f.close
      end
      return tempDirectory
    end

    def run_test_cases(directory, submission)
      Dir.glob(directory + 'input_*') do |file|
        run = directory + "main < " + file
        @stream = capture(:stdout) { system(run) }
        f = File.open(file.gsub("input", "output"), "w")
        f.write(@stream)
        f.close
        flash[:notice] = "Test Case Compiled"
      end
    end
end
