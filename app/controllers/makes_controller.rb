class MakesController < ApplicationController
  
  # create new
  def new
    @make = Make.new
    @test_case = TestCase.find(params[:test_case_id])
  end

  # create the make
  def create
    test_case = TestCase.find(params[:test_case_id])
    make = Make.create(make_params)

    if make.save
      test_case.make = make
      redirect_to test_case_url(test_case)
    else
      render :action => :new
    end
  end

  # shows a make
  def show
    @make = Make.find(params[:id])
  end

  # edit
  def edit
  end

  # update
  def update
  end

  # delete
  def destroy
    @make = Make.find(params[:id])
    @make.destroy
    redirect_to :back
  end

  private
    def make_params
      params.require(:make).permit(:name, :test_case, :data)
    end
end
