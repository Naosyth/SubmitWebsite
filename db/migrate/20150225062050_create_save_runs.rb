class CreateSaveRuns < ActiveRecord::Migration
  def change
    create_table :save_runs do |t|
      t.text :difference
      t.boolean :pass
      t.text :output
      t.string :input_name
      t.belongs_to :submission

      t.timestamps
    end
  end
end
