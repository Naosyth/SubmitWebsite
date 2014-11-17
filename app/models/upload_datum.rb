class UploadDatum < ActiveRecord::Base
  belongs_to :test_case
  belongs_to :submission
  has_many :comments

  def create
  	self.name = "test"
  end

end
