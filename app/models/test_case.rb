class TestCase < ActiveRecord::Base
  belongs_to :assignment
  has_many :upload_data

  def create_directory(path)
    upload_data.each do |upload_data|
      output = path + upload_data.name
      f = File.open(output, "w" )
      f.write(upload_data.contents)
      f.close
    end
  end

  def compile_code(path)
    make = "make -C " + path
    if system(make)
      Dir.glob(path + 'input_*') do |file|
        run = path + "main < " + file
        stream = capture(:stdout) { system(run) }
        f = File.open(file.gsub("input", "output"), "w")
        f.write(stream)
        upload = upload_data.new()
        upload.make_file(file.gsub(path, "").gsub("input", "output"), stream, "text/plain")
        upload.save
        f.close
      end
    else
      capture(:stderr) { system(make) }
    end
  end
end
