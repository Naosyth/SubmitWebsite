class UploadDatum < ActiveRecord::Base
  belongs_to :test_case
  belongs_to :submission
  has_many :comments

  validates :name, presence: true
  validate :ensure_unique_name

  def create_file(file_data)
  	self.name = file_data.original_filename
  	self.contents = file_data.read
  	self.file_type = file_data.content_type
  end

  def make_file(name, file_data, type)
    self.name = name
    self.contents = file_data
    self.file_type = type
    self.save
  end

  def source
    return test_case unless test_case.nil?
    return submission unless submission.nil?
  end

  private
  def ensure_unique_name
    source.upload_data.each do |file|
      file.destroy if file.name == name and file != self
    end
  end
end
