class Assignment < ActiveRecord::Base
  belongs_to :course
  has_many :submissions
  has_one :test_case

  validates :name, presence: true
  validates :description, presence: true
  validates :start_date, presence: true
  validates :due_date, presence: true
  validates :total_grade, presence: true
  validate :due_date_after_start_date

  after_save :create_submissions_for_students
  after_save :create_test_case

  def create_submissions_for_students
    course.users.select { |user| user.has_local_role? :student, course }.each do |student|
        submission = submissions.create(user: student) unless submissions.exists?(user: student)
    end
  end

  def create_test_case
    test_case = TestCase.create(:assignment_id => id)
  end

  private
  def due_date_after_start_date
      errors.add(:due_date, "can't be before start date") if due_date < start_date
  end
end
