class User < ActiveRecord::Base
  has_and_belongs_to_many :courses
  has_many :submissions

  acts_as_authentic do |c|
    c.login_field = 'email'
  end
end
