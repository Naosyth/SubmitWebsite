class Make < ActiveRecord::Base
  belongs_to :test_case

  after_save :remove_saved_runs
  before_destroy :remove_saved_runs

  def build(params, tc)
    self.test_case = tc
    self.data = params[:data]
    self.name = params[:name]
  end

  def remove_saved_runs
    test_case.assignment.remove_saved_runs
  end
end
