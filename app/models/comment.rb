class Comment < ActiveRecord::Base
  belongs_to :upload_datum
  validates :contents, presence: true
  validates :line, numericality: { :greater_than => 0, only_integer: true }, presence: true

  def create_comment(file_data)
    self.row = file_data.original_filename
    self.text = file_data.read
    self.type = file_data.content_type
  end


end
