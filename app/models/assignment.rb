class Assignment < ActiveRecord::Base
  belongs_to :course
  has_many :submissions
  has_one :test_case

before_create :create_test_case
  def create_submissions_for_students
    course.users.select { |user| user.has_local_role? :student, course }.each do |student|
        submission = submissions.create(user: student) unless submissions.exists?(user: student)
    end
  end

  def create_test_case
    test_case = TestCase.create(:assignment_id => id)
  end
end
