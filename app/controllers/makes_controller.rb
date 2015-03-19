class MakesController < ApplicationController
  
  # create the make
  def create
    test_case = TestCase.find(params[:test_case_id])
    test_case.make = Make.new
    test_case.make.build(make_params, test_case)

    if test_case.make.save
      flash.now[:notice] = "Makefile Created"
    else
      flash.now[:notice] = "Failed To Create Makefile"
      test_case.make = nil
    end
    respond_to do |format|
      format.js { render :action => "refresh", :locals => { :@test_case => test_case } }
    end
  end

  # update
  def update
    @make = Make.find(params[:id])

    if @make.update_attributes(make_params)
      flash.now[:notice] = "Makefile Updated"
    else
      flash.now[:notice] = "Failed To Update Makefile"
    end
    redirect_to :back
  end

  # delete
  def destroy
    make = Make.find(params[:id])
    test_case = TestCase.find(make.test_case_id)
    make.destroy
    flash.now[:notice] = "Makefile Removed"
    respond_to do |format|
      format.js { render :action => "refresh", :locals => { :@test_case => test_case } }
    end
  end

  private
    def make_params
      params.require(:make).permit(:name, :data)
    end
end
