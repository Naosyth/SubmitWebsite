class Comment < ActiveRecord::Base
  belongs_to :submission
end
