class UploadDatum < ActiveRecord::Base
  belongs_to :test_case
  belongs_to :submission
end
