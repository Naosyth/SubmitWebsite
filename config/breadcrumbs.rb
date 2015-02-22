crumb :root do
  link "Home", dashboard_path
end

crumb :courses do
  link "Courses", courses_url
end

crumb :course do |course|
  link course.name, course
  parent :courses
end

crumb :course_users do |course|
  link "Enrolled Users", courses_users_url(course)
  parent :course, course
end

crumb :course_edit do |course|
  link "Edit", edit_course_url(course)
  parent :course, course
end

crumb :course_grades do |course|
  link "Grades", course_all_grades_url(course)
  parent :course, course
end

crumb :assignment do |assignment|
  link assignment.name, assignment
  parent :course, assignment.course
end

crumb :assignment_edit do |assignment|
  link "Edit", assignment
  parent :assignment, assignment
end

crumb :assignment_grades do |assignment|
  link "Grades", assignment
  parent :assignment, assignment
end

crumb :assignment_new do |course|
  link "New Assignment", select_assignment_url
  parent :course, course
end

crumb :assignment_copy do |course|
  link "Import Assignment", select_assignment_url
  parent :course, course
end

crumb :test_case do |test_case|
  link "Test Case", test_case
  parent :assignment, test_case.assignment
end

crumb :run_method do |run_method|
  link "Run Method", run_method
  parent :test_case, run_method.test_case
end

crumb :run_method_new do |test_case|
  link "New Run Method"
  parent :test_case, test_case
end

crumb :input do |input|
  link input.name, input
  parent :run_method, input.run_method
end

crumb :input_new do |run_method|
  link "Input"
  parent :run_method, run_method
end

crumb :makes do |make|
  link "Make File"
  parent :test_case, make.test_case
end

crumb :makes_new do |test_case|
  link "Make File"
  parent :test_case, test_case
end

crumb :submission do |submission|
  if current_user.has_local_role? :student, submission.assignment.course
    link submission.user.name, submission
    parent :course, submission.assignment.course
  else
    link submission.user.name, submission
    parent :assignment, submission.assignment
  end
end

crumb :submission_run do |submission|
  link "Test Run"
  parent :submission, submission
end

# crumb :projects do
#   link "Projects", projects_path
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).