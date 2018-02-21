class TestController < ApplicationController
  def test
    @obj = Obj.find(params[:id])
    @obj.test_attr_linklist = 'http://google.com'
    @obj.save!
    render :plain => 'ok'
    #redirect_to :back
  end
end
