class UploadDatum < ActiveRecord::Base
  belongs_to :test_case
  belongs_to :submission
  has_many :comments

  def create_file(file_data)
  	self.name = file_data.original_filename
  	self.contents = file_data.read
  	self.file_type = file_data.content_type
  end

  def source
    return test_case unless test_case.nil?
    return submission unless submission.nil?
  end
end
