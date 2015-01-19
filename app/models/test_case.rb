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
    
    Dir.glob(path + 'input_*') do |file|
      shell = create_run_script(path, "main", file)
      stdin, stdout, stderr = Open3.popen3(shell)
      stream = stdout.read
      f = File.open(file.gsub("input", "output"), "w")
      f.write(stream)
      upload = upload_data.new()
      upload.make_file(file.gsub(path, "").gsub("input", "output"), stream, "text/plain")
      upload.save
      f.close
    end
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
