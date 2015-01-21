class Input < ActiveRecord::Base
  belongs_to :run_method

  def add(name, description, data, output, visible)
    self.name = name
    self.description = description
    self.data = data
    self.output = output
    self.student_visible = visible
    self.save 
  end
end
