class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :upload_data
  has_many :run_saves

  after_create :set_note_empty

  # This should be moved to the model
  def set_note_empty
    self.note = ""
    self.save
  end

  # Sets up the directory
  def create_directory
    # Creates a temporary directory for the student files
    tempDirectory = Rails.configuration.compile_directory + user.name.tr(" ", "_") + '_' + id.to_s + '/'
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
  def run_test_cases(hidden)
    stream = {}
    directory = create_directory
    
    assignment.test_case.run_methods.each do |run|
      if hidden
        inputs = run.inputs.select { |i| i.student_visible } 
      else
        inputs = run.inputs
      end

      inputs.each do |input|
        # Check if there needs to be a new run
        return if not run_saves.select { |s| s.input_name == input.name }.first.blank?

        # Make output file
        input_file = directory + input.name
        f = File.open(input_file, "w")
        f.write(input.data)
        f.close
        shell = create_run_script(directory, run.run_command, input_file)
        stdin, stdout, stderr = Open3.popen3(shell)
        stream[:stdout] = stdout.read
        stream[:stderr] = stderr.read 
        save = run_saves.new

        # Check if the process errored
        f = File.open(input_file, "w")
        if not stream[:stderr].empty?
          stream[:stderr].gsub! directory, ""
          stream[:stderr] += "\nProcess Exceeded Max CPU Time of: " + assignment.test_case.cpu_time.to_s + " seconds." if stream[:stderr].include? "Kill" or stream[:stderr].include? "Cputime"
          f.write(stream[:stderr])
          f.close
          difference = "ERROR"
          save.output = stream[:stderr]
        else 
          f.write(stream[:stdout])
          f.close
          save.output = stream[:stdout]
          difference = Diffy::Diff.new(stream[:stdout], input.output, :include_plus_and_minus_in_html => true, :allow_empty_diff => true).to_s(:text)
        end

        save.difference = difference
        save.input_name = input.name
        save.pass = difference.empty?

        save.save
      end
    end
    
    FileUtils.rm_rf(directory)
  end

  # Grade the submission 
  def instructor_grade
    directory = create_directory
    gradeData = {}

    # Compiles and runs the program
    gradeData = compile(directory)
    gradeData[:correct] = run_test_cases(directory, false) if gradeData[:compile]

    FileUtils.rm_rf(directory)
    return gradeData
  end

  def remove_saved_runs
    run_saves.each do |rs|
      rs.destroy
    end
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
