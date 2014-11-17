class UploadDatum < ActiveRecord::Base
  belongs_to :test_case
  belongs_to :submission
  has_many :comments

  def create_file(file_data)
  	self.name = file_data.original_filename
  	self.contents = file_data.read
  end

end
