class TestCase < ActiveRecord::Base
  belongs_to :assignment
  has_many :upload_data
  has_one :make
  has_many :run_methods

  def create_directory(path)
    upload_data.each do |upload_data|
      output = path + upload_data.name
      f = File.open(output, "w" )
      f.write(upload_data.contents)
      f.close
    end
    if not make.nil?
      output = path + make.name
      f = File.open(output, "w")
      f.write(make.data)
      f.close
    end
  end

  def compile_code(path)
    if not make.nil?
      make = "make -C " + path
      if not system(make)
        return capture(:stderr) { system(make) }
      end
    end
    
    run_methods.each do |run|
      run.inputs.each do |file|
        output = path + file.name
        f = File.open(output, "w" )
        f.write(file.data)
        f.close
        shell = create_run_script(path, run.run_command, output)
        stdin, stdout, stderr = Open3.popen3(shell)
        stream = stdout.read
        file.output = stream
        puts stream
        puts "=========================================================================================================================="
        file.save
      end
    end
    return nil
  end

  private
    def create_run_script(directory, command, file)
      run = directory + command + " < " + file
      shell = "#!/bin/bash\n"
      shell = shell + "ulimit -t " + cpu_time.to_s
      shell = shell + "\n" 
      shell = shell + "ulimit -c " + core_size.to_s
      shell = shell + "\n"
      shell = shell + run
      return shell
    end
end
