class Course < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :assignments

  TERMS = %w[spring fall summer winter]
end
