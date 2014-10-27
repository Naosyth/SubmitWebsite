class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :upload_data
  has_many :comments
end
