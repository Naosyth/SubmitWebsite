class RunMethod < ActiveRecord::Base
  has_many :inputs
  belongs_to :test_case
end
