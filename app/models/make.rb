class Make < ActiveRecord::Base
  belongs_to :test_case

  after_save :remove_saved_runs
  before_destroy :remove_saved_runs

  def remove_saved_runs
    run_method.test_case.assignment.remove_saved_runs
  end
end
