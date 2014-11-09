module CoursesHelper
  def require_admin
    if not current_user.has_role? :admin
      flash[:notice] = "That action is only available to admins"
      redirect_to dashboard_url
    end
  end

  def require_instructor
    return if current_user.has_role? :admin
    
    if not current_user.has_role? :instructor
      flash[:notice] = "That action is only available to instructors"
      redirect_to dashboard_url
    end
  end

def require_instructor_owner
    return if current_user.has_role? :admin

    course = Course.find(params[:id])
    if not current_user.has_role? :instructor, course
      flash[:notice] = "That action is only available to the instructor of the course"
      redirect_to dashboard_url
    end
  end

  def require_student
    return if current_user.has_role? :admin

    if not current_user.has_role? :student
      flash[:notice] = "That action is only available to students"
      redirect_to dashboard_url
    end
  end

  def require_student_enrolled
    return if current_user.has_role? :admin

    course = Course.find(params[:id])
    if not current_user.has_local_role? :student, course
      flash[:notice] = "That action is only available to students enrolled in the course"
      redirect_to dashboard_url
    end
  end

  def require_enrolled
    return if current_user.has_role? :admin

    course = Course.find(params[:id])
    if not current_user.courses.include? course
      flash[:notice] = "That action is only available to users enrolled in the course"
      redirect_to dashboard_url
    end
  end
end
