class MakesController < ApplicationController
  
  # create new
  def new
    @make = Make.new
    @test_case = TestCase.find(params[:test_case_id])
  end

  # create the make
  def create
    @test_case = TestCase.find(params[:test_case_id])
    make = Make.create(make_params)

    if make.save 
      submissions = test_case.assignment.submissions
      submissions.each do |s|
        s.remove_cached_runs
      end
      if @test_case.save 
        @test_case.make = make
        redirect_to :back
      else
        flash[:notice] = "Error Saving Makefile"
      end
    end
  end

  # GET /makes/1.json
  def show
    @make = Make.find(params[:id])
  end

  # edit
  def edit
  end

  # update
  def update

  end

  # DELETE 
  def destroy
    @make = Make.find(params[:id])
    @make.destroy
    submissions = @make.test_case.assignment.submissions
    submissions.each do |s|
      s.remove_cached_runs
    end
    redirect_to :back
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def make_params
      params.require(:make).permit(:name, :test_case, :data)
    end
end
