class SaveRuns < ActiveRecord::Base
  belongs_to :submission

  def new
    put "something ehre ============================"
  end
end
