class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :upload_data

  # Sets up the directory
  def create_directory
    # Creates a temporary directory for the student files
    tempDirectory = Rails.configuration.compile_directory + user.name + '_' + id.to_s + '/'
    if not Dir.exists?(tempDirectory) 
      Dir.mkdir(tempDirectory)
    end

    # Adds in all the student files 
    upload_data.each do |upload_data|
      output = tempDirectory + upload_data.name
      f = File.open(output, "w" )
      f.write(upload_data.contents)
      f.close
    end

    # Adds in the test case files
    assignment.test_case.upload_data.select { |u| u.name.include? "input" or u.name.downcase == "makefile" }.each do |upload_data|
      output = tempDirectory + upload_data.name
      f = File.open(output, "w" )
      f.write(upload_data.contents)
      f.close
    end
    return tempDirectory
  end

  # Compiles and runs the program
  def compile(directory, flash)
    make = "make -C " + directory
    if system(make)
      flash[:notice] = "Compiled"
      return true
    else
      stream = capture(:stderr) { system(make) }
      flash[:notice] = "Not Compiled"
      flash[:comperr] = stream
      return false
    end
  end

  # Runs the code on a test case input
  def run_test_cases(directory)
    correct = {}
    correct[:total] = 0
    correct[:correct] = 0
    Dir.glob(directory + 'input_*') do |file|
      # make output file
      cputime = "/usr/bin/ulimit -t 2"
      run = directory + "main < " + file
      shell = "#!/bin/bash\nulimit -t 1\nulimit -t\n" + run
      f = File.open(file.gsub("input", "run"), "w")
      f.write(shell)
      f.close
      # stream = capture(:stdout) { system(run) }
      Open3.popen3(cputime)
      stdin, stdout, stderr = Open3.popen3(shell)
      stream = stderr.read
      f = File.open(file.gsub("input", "output"), "w")
      f.write(stream)
      f.close

      # make diff file
      cmpName = file.gsub(directory + "input", "output")
      test = assignment.test_case.upload_data.select { |out| out.name == cmpName }
      compare = test.first.contents
      difference = Diffy::Diff.new(stream, compare, :include_plus_and_minus_in_html => true, :allow_empty_diff => true).to_s(:text)
      f = File.open(file.gsub("input", "diff"), "w")
      f.write(difference)
      f.close

      # check if the test was correct
      correct[:total] = correct[:total] + 1
      if difference.empty?
        correct[:correct] = correct[:correct] + 1
      end
    end
    return correct
  end

  # Grade the submission 
  def instructor_grade
    directory = create_directory
    gradeData = {}

    # Compiles and runs the program
    if compile(directory, gradeData)
      gradeData[:compiled] = true
      gradeData[:correct] = run_test_cases(directory)
    else
      gradeData[:compiled] = false
    end
    FileUtils.rm_rf(directory)
    return gradeData
  end
end
