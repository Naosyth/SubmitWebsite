class User < ActiveRecord::Base
  ROLES = %w[admin instructor student grader]
  rolify

  has_and_belongs_to_many :courses
  has_many :submissions

  acts_as_authentic do |c|
    c.login_field = 'email'
  end

  def update_course_roles(roles, scope)
    ROLES.each do |role|
      if roles.include? role
        add_role role, scope
      else
        remove_role role, scope
      end
    end
    if not roles.include? "student"
      scope.assignments.each do |assignment|
        assignment.remove_user_submissions self
      end
    end
  end

  def has_local_role?(role, scope)
    return roles.find_by(name: role, resource_type: scope.class.name, resource_id: scope.id) != nil
  end

end
