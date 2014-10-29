class User < ActiveRecord::Base
  ROLES = %w[admin instructor student]

  has_and_belongs_to_many :courses
  has_many :submissions

  acts_as_authentic do |c|
    c.login_field = 'email'
  end

  def admin?
    return role == "admin"
  end

  def instructor?
    return role == "instructor"
  end

  def student?
    return role == "student"
  end
end
