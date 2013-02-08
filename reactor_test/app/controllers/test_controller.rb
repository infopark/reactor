# -*- encoding : utf-8 -*-
class TestController < ApplicationController
  def test
    @obj = Obj.find(params[:id])
    @obj.test_attr_linklist = 'http://google.com'
    @obj.save!
    render :text => 'ok'
    #redirect_to :back
  end
end
