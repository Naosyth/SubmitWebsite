class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :upload_data

  after_create :set_note_empty

  def set_note_empty
    self.note = ""
    self.save
  end

  # Sets up the directory
  def create_directory
    # Creates a temporary directory for the student files
    tempDirectory = Rails.configuration.compile_directory + user.name + '_' + id.to_s + '/'
    if not Dir.exists?(tempDirectory) 
      Dir.mkdir(tempDirectory)
    end

    # Adds in all the student files 
    upload_data.each do |upload_data|
      if upload_data.file_type != 'application/pdf'
        output = tempDirectory + upload_data.name
        f = File.open(output, "w" )
        f.write(upload_data.contents)
        f.close
      end
    end

    # Adds in the makefile if exists
    if not assignment.test_case.make.nil?
      File.delete(tempDirectory + "makefile") if File.exists?(tempDirectory + "makefile")
      output = tempDirectory + assignment.test_case.make.name
      f = File.open(output, "w")
      f.write(assignment.test_case.make.data)
      f.close
    end
    return tempDirectory
  end

  # Compiles and runs the program
  def compile(directory)
    flash = {}
    make = "make -C " + directory
    if system(make)
      flash[:compile] = true
      return flash
    else
      stream = capture(:stderr) { system(make) }
      flash[:compile] = false
      flash[:comperr] = stream
      return flash
    end
  end

  # Runs the code on a test case input
  def run_test_cases(directory, student)
    correct = {}
    stream = {}
    correct[:total] = 0
    correct[:correct] = 0
    
    assignment.test_case.run_methods.each do |run|
      if student
        submit_run = run.inputs.select {|i| i.student_visible} 
      else
        submit_run = run.inputs
      end
      submit_run.each do |file|
        # make output file
        output = directory + file.name
        f = File.open(output, "w" )
        f.write(file.data)
        f.close
        shell = create_run_script(directory, run.run_command, output)
        stdin, stdout, stderr = Open3.popen3(shell)
        stream[:stdout] = stdout.read
        stream[:stderr] = stderr.read 

        # Check if the process errored
        f = File.open(output, "w")
        if not stream[:stderr].empty?
          stream[:stderr].gsub! directory, ""
          if stream[:stderr].include? "Kill" or stream[:stderr].include? "Cputime" 
            stream[:stderr] = stream[:stderr] + "\nProcess Exceeded Max CPU Time of: " + assignment.test_case.cpu_time.to_s + " seconds."
          end
          f.write(stream[:stderr])
          f.close
          difference = "ERROR"
        else 
          f.write(stream[:stdout])
          f.close
          difference = Diffy::Diff.new(stream[:stdout], file.output, :include_plus_and_minus_in_html => true, :allow_empty_diff => true).to_s(:text)
        end

        # Make Diff file
        f = File.open(output.gsub(file.name, file.name + "diff"), "w")
        f.write(difference)
        f.close

        # check if the test was correct
        correct[:total] = correct[:total] + 1
        if difference.empty?
          correct[:correct] = correct[:correct] + 1
        end
      end
    end
    return correct
  end

  # Grade the submission 
  def instructor_grade
    directory = create_directory
    gradeData = {}

    # Compiles and runs the program
    gradeData = compile(directory)
    if gradeData[:compile]
      gradeData[:correct] = run_test_cases(directory, false)
    end
    FileUtils.rm_rf(directory)
    return gradeData
  end

  private
    # Creates a script to run on
    def create_run_script(directory, command, file)
      run = directory + command + " < " + file
      shell = "#!/bin/bash\n"
      shell = shell + "ulimit -t " + assignment.test_case.cpu_time.to_s
      shell = shell + "\n" 
      shell = shell + "ulimit -c " + assignment.test_case.core_size.to_s
      shell = shell + "\n"
      shell = shell + run
      return shell
    end
end
