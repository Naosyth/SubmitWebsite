class TestCase < ActiveRecord::Base
  belongs_to :assignment
  has_many :upload_datum
end
